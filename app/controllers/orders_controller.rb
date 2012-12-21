class OrdersController < ApplicationController

  before_filter :set_order_product, :only => [:email_info, :payment_info, :shipping_info, :confirm, :create]
  
  def new
    @order = Order.new(:order_type => Order::TYPES[params[:order_type].to_sym], :product_id => params[:product_id].to_i )
    @product = Product.find params[:product_id]

    if user_signed_in?
      @order.email = @order.email_confirmation = current_user.email
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
    if @order.valid_to_buy?
      render "payment_info_form"
    else
      render "email_info_form"
    end
  end

  def shipping_info
    if @order.valid_to_buy?
      render "shipping_info_form"
    else
      render "payment_info_form"
    end
  end
  
  def confirm
    if @order.valid_to_buy?
      render "confirm_form"
    else
      render "shipping_info_form"
    end
  end
  
  def create
    if @order.valid_to_buy?
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
      @product = Product.find params[:order][:product_id]
      @order = Order.new(params[:order])
    end

end
