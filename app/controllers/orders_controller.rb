class OrdersController < ApplicationController

  before_filter :require_login, :only => [:payment_info, :shipping_info, :confirm, :create, :reload_payment_order_info]
  before_filter :set_order_product, :only => [:new, :email_info, :payment_info, :shipping_info, :confirm, :create, :change_shipping_info]

  ADMIN_EMAIL = "adam@swapidy.com"

  def new
    session[:shop_type] = params[:shop_type] if params[:shop_type].present?
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
    render "payment_info_page"
  end

  def shipping_info
    #if current_user.could_order?(cart_amount)
      @order.enter_from_last_address if @order.shipping_address_blank?
      page_title "Shipping Address"
      render "shipping_info_page"
    #else
    #  page_title "Payment Information"
    #  render "payment_info_page"
    #end
  end
  
  def confirm
    if @order.valid? && @order.shipping_address_valid?
      current_user.copy_to_new_card
      render "confirm_form"
    else
      page_title "Shipping Address"
      render "shipping_info_page"
    end
  end
  
  def create
    if @order.valid? && @order.shipping_address_valid? && current_user.could_order?(ShoppingCart.cart_amount)
      if session[:shop_type] == "sell"
        begin
          Order.transaction do
            session[:cart_products][:sell].each do |obj_hash|
              @order.order_products.new(:product_id => obj_hash[:product_id], 
                                        :price => obj_hash[:price], 
                                        :using_condition => obj_hash[:using_condition], 
                                        :sell_or_buy => "sell")
            end

            if @order.save
                @order.delay.create_stamp_to_deliver(session[:shop_type])
                OrderNotifier.delay.start_processing(@order, session[:shop_type])
                OrderNotifier.delay.start_processing_for_admin(@order, session[:shop_type])
                ShoppingCart.clear_cart_products 
             end
          end          
          redirect_to "/orders/#{@order.id}"
        rescue Exception => e
          @order.errors.add(:shipping_stamp, " has errors to create: #{e.message}")
          page_title "Confirm Your Details"
          current_user.copy_to_new_card
          render "confirm_form"
        end
      elsif session[:shop_type] == "buy"
        begin
          Order.transaction do
            session[:cart_products][:buy].each do |obj_hash|
              @order.order_products.new(:product_id => obj_hash[:product_id], 
                                        :price => obj_hash[:price], 
                                        :using_condition => obj_hash[:using_condition], 
                                        :sell_or_buy => "buy")
            end            
            @order.payment_option = PaymentTransaction::METHODS[:pre_authorize]
            if @order.save
              @order.do_payment
              @order.delay.create_stamp_to_deliver(session[:shop_type])
              OrderNotifier.delay.start_processing(@order, session[:shop_type])
              OrderNotifier.delay.start_processing_for_admin(@order,session[:shop_type])
              ShoppingCart.clear_cart_products
            end
          end
          redirect_to "/orders/#{@order.id}"
          rescue Exception => e
            @order.errors.add(:shipping_stamp, " has errors to create: #{e.message}")
            page_title "Confirm Your Details"
            current_user.copy_to_new_card
            render "confirm_form" 
          end
      elsif session[:shop_type] == "swap"
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
            @order.payment_option = PaymentTransaction::METHODS[:pre_authorize]
            if @order.save
              @order.do_payment
              @order.delay.create_stamp_to_deliver(session[:shop_type])
              OrderNotifier.delay.start_processing(@order, session[:shop_type])
              OrderNotifier.delay.start_processing_for_admin(@order,session[:shop_type])
              ShoppingCart.clear_cart_products 
            end
          end
          redirect_to "/orders/#{@order.id}"
        rescue Exception => e
          @order.errors.add(:shipping_stamp, " has errors to create: #{e.message}")
          page_title "Confirm Your Details"
          current_user.copy_to_new_card
          render "confirm_form"
        end
      end      
    else
      page_title "Confirm Your Details"
      current_user.copy_to_new_card
      render "confirm_form"
    end
  end

  def show
    @order = Order.find params[:id]
    render "show_trade_ins"
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

  def change_paypal_email
    @user = User.find current_user.id
    @user.paypal_email = params[:user][:paypal_email]

    #if @user.paypal_email == current_user.paypal_email
    #  @error_message = "Please enter another email to change!"
    #els
    if session[:signed_in_via_facebook].nil? 
      @error_message = "Please enter vaild password" unless @user.valid_password?(params[:user][:current_password])
    end
    
    if @error_message.nil? && @user.save
      current_user.email = @user.email
      @success_message = "Your email has changed successfully!"
    end 
    @return_content = render_to_string(:partial => "/orders/change_paypal_email_form", :locals => {:user => @user})
  end

  def change_certified_name
    @user = User.find current_user.id
    @user.certified_name = params[:user][:certified_name]

    #if @user.certified_name == current_user.certified_name
    #  @error_message = "Please enter another certified_name to change!"
    #els
    if session[:signed_in_via_facebook].nil? 
      @error_message = "Please enter vaild password" unless @user.valid_password?(params[:user][:current_password])
    end
    
    if @error_message.nil? && @user.save
      current_user.certified_name = @user.certified_name
      @success_message = "Your certified name has changed successfully!"
    end 
     @return_content = render_to_string(:partial => "/orders/change_certified_name_form", :locals => {:user => @user})
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
      redirect_to "/" if ShoppingCart.cart_products[:sell].empty? && ShoppingCart.cart_products[:buy].empty?
    end
    
end

