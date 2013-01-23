class OrdersController < ApplicationController

  before_filter :require_login, :only => [:payment_info, :shipping_info, :confirm, :create]
  before_filter :set_order_product, :only => [:email_info, :payment_info, :shipping_info, :confirm, :create, :change_shipping_info]
  
  def new
    @order = Order.new(:order_type => params[:order_type], :product_id => params[:product_id].to_i )
    @product = Product.find params[:product_id]
    (redirect_to "/"; return) unless @product

    @order.using_condition = params[:using_condition] || (params[:order] && params[:order][:using_condition])
    @order.honey_price = @product.price_for(@order.using_condition)
    
    session[:creating_order] = {:token_key => @order.generate_token_key, :product_id => @order.product_id, 
                                :order_type => @order.order_type, :using_condition => @order.using_condition}
    if @order.using_condition.nil? || !Product::USING_CONDITIONS.values.include?(@order.using_condition) || @order.honey_price.nil?
      @error_message = "You need to select at least one of the conditions!"
      params["for"] = params[:order_type] && params[:order_type] == Order::TYPES[:order] ? "buy" : "sell"
      render "/products/show"
      return
    end
    
    if user_signed_in?
      render @order.is_trade_ins? ? "payment_info_trade_ins" : "payment_info_form"
    else
      @user = User.new
      render "email_info_form"
    end
  end
  
  def email_info
    render "email_info_form"
  end
  
  def payment_info
    render @order.is_trade_ins? ? "payment_info_trade_ins" : "payment_info_form"
  end

  def shipping_info
    if current_user.could_order?(@order)
      @order.enter_from_last_address if @order.shipping_address_blank?
      render "shipping_info_page"
    else
      render @order.is_trade_ins? ? "payment_info_trade_ins" : "payment_info_form"
    end
  end
  
  def confirm
    if @order.valid? && @order.shipping_address_valid?
      render @order.is_trade_ins? ? "confirm_trade_ins" : "confirm_form"
    else
      render "shipping_info_page"
    end
  end
  
  def create
    if @order.valid? && @order.shipping_address_valid? && current_user.could_order?(@order)
      @order.weight_lb = @order.product.weight_lb

      @order.honey_price = @product.honey_price
      #@order.using_condition = @product.using_condition
      begin
        Order.transaction do
          @order.save
          @shipping_stamp = @order.create_new_stamp
        end
        session[:creating_order] = nil
        redirect_to "/orders/#{@order.id}"
      rescue Exception => e
        @order.errors.add(:shipping_stamp, " has errors to create: #{e.message}")
        render "confirm_form"
      end
    else
      render "confirm_form"
    end
  end
  
  def show
    @order = Order.find params[:id]
    render @order.is_trade_ins? ? "show_trade_ins" : "show_order"
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
    Rails.logger.info @return_content
  end
  
  def change_shipping_info
    if @order.valid? && @order.shipping_address_valid?
      @success_message = "Your shipping address have changed successfully!"
      @changed_content = render_to_string(:partial => "/orders/shipping_label", :locals => {:order => @order})
    end
    @return_content = render_to_string(:partial => "/orders/shipping_form", :locals => {:order => @order, :submit_title => "Change"})
  end
  
  private

    def set_order_product
      @order = Order.new(params[:order])
      @order.status = Order::STATUES[:pending]
      @order.user = current_user
      @order.shipping_country = "US"
      @product = @order.product = Product.find(params[:order][:product_id])
      @order.honey_price = @product.price_for(@order.using_condition)
      redirect_to "/" if session[:creating_order].nil? || session[:creating_order][:token_key] != @order.token_key
    end

end
