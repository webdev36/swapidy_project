class OrdersController < ApplicationController

  before_filter :require_login, :only => [:payment_info, :shipping_info, :confirm, :create, :reload_payment_order_info]
  before_filter :set_order_product, :only => [:new, :email_info, :payment_info, :shipping_info, :confirm, :create, :change_shipping_info]

  def new
    if user_signed_in?
      page_title "Payment Information"
      render "payment_info_page"
    else
      @user = User.new
      render "email_info_form"
    end
  end
  
  def reload_payment_order_info
    respond_to do |format|
      format.js {
        @return_content = render_to_string(:partial => "/orders/payment_info_form")
      }
    end
  end
  
  def email_info
    render "email_info_form"
  end
  
  def payment_info
    page_title "Payment Information"
    render @order.is_trade_ins? ? "payment_info_trade_ins" : "payment_info_page"
  end

  def shipping_info
    if current_user.could_order?(cart_amount)
      @order.enter_from_last_address if @order.shipping_address_blank?
      page_title "Shipping Address"
      render "shipping_info_page"
    else
      page_title "Payment Information"
      render @order.is_trade_ins? ? "payment_info_trade_ins" : "payment_info_page"
    end
  end
  
  def confirm
    if @order.valid? && @order.shipping_address_valid?
      render "confirm_form"
    else
      page_title "Shipping Address"
      render "shipping_info_page"
    end
  end
  
  def create
    if @order.valid? && @order.shipping_address_valid? && current_user.could_order?(cart_amount)
      begin
        Order.transaction do
          session[:cart_products][:sell].each do |obj_hash|
            @order.order_products.new(:product_id => obj_hash[:product_id], 
                                      :price => obj_hash[:price], 
                                      :using_condition => obj_hash[:using_condition], 
                                      :sell_or_buy => "sell")
          end
          session[:cart_products][:buy].each do |obj_hash|
            @order.order_products.new(:product_id => obj_hash[:product_id], 
                                      :price => obj_hash[:price], 
                                      :using_condition => obj_hash[:using_condition], 
                                      :sell_or_buy => "buy")
          end
          if @order.save
            OrderNotifier.start_processing(@order).deliver
            clear_cart_products 
          end
        end
        redirect_to "/orders/#{@order.id}"
      rescue Exception => e
        @order.errors.add(:shipping_stamp, " has errors to create: #{e.message}")
        page_title "Confirm Your Details"
        render "confirm_form"
      end
    else
      page_title "Confirm Your Details"
      render "confirm_form"
    end
  end

  def show
    @order = Order.find params[:id]
    render "show_order"
  end

  def change_email
    @user = User.find current_user.id
    @user.email = params[:user][:email]
    if @user.email == current_user.email
      @error_message = "Please enter another email to change!"
    elsif session[:signed_in_via_facebook].nil? 
      @error_message = "Please enter vaild password" unless @user.valid_password?(params[:user][:current_password])
    end
    
    if @error_message.nil? && @user.save
      current_user.email = @user.email
      @success_message = "Your email has changed successfully!"
      @changed_content = render_to_string(:partial => "/orders/email_label", :locals => {:user => @user})
    end 
    @return_content = render_to_string(:partial => "/orders/change_email_form", :locals => {:user => @user})
  end

  def change_shipping_info
    if @order.valid? && @order.shipping_address_valid?
      @success_message = "Your shipping address has been updated successfully!"
      @changed_content = render_to_string(:partial => "/orders/shipping_label", :locals => {:order => @order})
    elsif @order.candidate_addresses && !@order.candidate_addresses.empty?
      @candidate_content = render_to_string(:partial => "/orders/candidate_address_form", :locals => {:order => @order})
    end
    @return_content = render_to_string(:partial => "/orders/shipping_form", :locals => {:order => @order, :submit_title => "Change"})
  end

  private

    def set_order_product
      @order = params[:order] ? Order.new(params[:order]) : Order.new
      @order.status = Order::STATUES[:pending]
      @order.user = current_user
      @order.shipping_country = "US"
      redirect_to "/" if cart_products[:sell].empty? && cart_products[:buy].empty?
    end

    
end
