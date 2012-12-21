class OrdersController < ApplicationController

  before_filter :require_login, :only => [:payment_info, :shipping_info, :confirm, :create]
  before_filter :set_order_product, :only => [:email_info, :payment_info, :shipping_info, :confirm, :create]
  
  def new
    @order = Order.new(:order_type => params[:order_type], :product_id => params[:product_id].to_i )
    @product = Product.find params[:product_id]

    if user_signed_in?
      render "payment_info_form"
    else
      @user = User.new
      render "email_info_form"
    end
  end
  
  def email_info
    render "email_info_form"
  end
  
  def payment_info
    render "payment_info_form"
  end

  def shipping_info
    if current_user.able_to_buy? @product
      render "shipping_info_form"
    else
      render "payment_info_form"
    end
  end
  
  def confirm
    if @order.valid? && current_user.able_to_buy?(@product)
      render "confirm_form"
    else
      render "shipping_info_form"
    end
  end
  
  def create
    if @order.valid? && current_user.able_to_buy?(@product)
      if user_signed_in?
        @order.user = current_user
      else
        user = User.find_by_email(@order.email) rescue nil
        user = User.create(:email => @order.email, :address => @order.shipping_address, :password => "123456", :password_confirmation => "123456")
        @order.user = user
      end
      @order.honey_price = @product.honey_price
      @order.using_condition = @product.using_condition
      @order.save
      #TODO: send email to user
      redirect_to "/orders/show"
    else
      render "confirm_form"
    end
  end
  
  def show
  end
  
  private

    def set_order_product
      @order = Order.new(params[:order])
      @order.status = Order::STATUES[:pending]
      @product = Product.find(params[:order][:product_id])
    end

end
