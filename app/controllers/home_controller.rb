class HomeController < ApplicationController

  layout 'application_with_left_menu', :only => [:static_page, :contact_us]
  
  ADMIN_EMAILS = %w(adam@swapidy.com pulkit@swapidy.com)

  before_filter :require_login, :only => [:settings]

  def index
    render "index", :layout => 'application_with_slider'
  end

  def transactions
    page_title "Transactions"
    render "transactions", :layout => 'application_with_bg_contain'
  end

  def static_page
    page_title params[:page_title]
    render params[:content]
  end

  def contact_us
    page_title "Contact Us"
    unless verify_recaptcha()
      @error_message = "Please enter the text correctly."
      return
    end

    @contact = params[:contact]
    if @contact.nil? || (@contact[:email] || "").blank? || (@contact[:subject] || "").blank? || (@contact[:message] || "").blank?
      @error_message = "You have to enter all of the fields."
      return
    end

    unless @contact[:email].match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
      @error_message = "Please enter a valid email."
      return
    end

    ADMIN_EMAILS.each {|email| UserNotifier.contact_us(email, @contact).deliver }
    flash[:thank_message] = "Thank you for contacting us. We'll respond within 24 hours."

    redirect_to "/contact_us"
  end

  def disconect_fb
    session[:signed_in_via_facebook] = nil
    @provider = current_user.user_providers.first
    @provider.destroy if @provider
    session[:disconnect_facebook] = true
    redirect_to "/users/edit"
  end

  def swap_product
    ShoppingCart.add_cart_product(:type => params[:type],:price => params[:price],:product_id => params[:product_id],:using_condition => params[:condition])
    @changed_type = params[:type] && params[:type] == "sell" ? :sell : :buy 
    @return_content = []
    respond_to do |format|
      format.js {
        #@return_content[0] = render_to_string(:partial => "/home/shopping_cart")
        @return_content[1] = render_to_string(:partial => "/layouts/shopping_cart")
        @return_content
      }
    end
  end

  def del_product
    @return_content = []
    if session[:cart_products]
      index_for_sell = session[:cart_products][:sell].index{|x| x[:order_product_id].to_i == params[:order_id].to_i}
      if index_for_sell && index_for_sell.to_i >= 0
        session[:cart_products][:sell].delete_at(index_for_sell)
        @changed_type = :sell
      else
        index_for_buy = session[:cart_products][:buy].index{|x| x[:order_product_id].to_i == params[:order_id].to_i}
        if index_for_buy && index_for_buy.to_i >= 0
          session[:cart_products][:buy].delete_at(index_for_buy) 
          @changed_type = :buy
        end
      end
    end
    respond_to do |format|
      format.js {
        #@return_content[0] = render_to_string(:partial => "/home/shopping_cart")
        @return_content[1] = render_to_string(:partial => "/layouts/shopping_cart")
        @return_content
      }
    end
  end
  def clear_checkout_item    
    @return_content = []
    
    session[:cart_products][:buy] = []
    session[:cart_products][:sell] = []
    
    respond_to do |format|
      format.js {
        #@return_content[0] = render_to_string(:partial => "/home/shopping_cart")
        @return_content[1] = render_to_string(:partial => "/layouts/shopping_cart")
        @return_content
      }      
    end
  end
end
