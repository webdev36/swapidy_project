class OrdersController < ApplicationController

  before_filter :require_login, :only => [:payment_info, :shipping_info, :confirm, :create]
  before_filter :set_order_product, :only => [:email_info, :payment_info, :shipping_info, :confirm, :create]
  
  def new
    @order = Order.new(:order_type => params[:order_type], :product_id => params[:product_id].to_i )
    @product = Product.find params[:product_id]

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
      render "shipping_info_form"
    else
      render @order.is_trade_ins? ? "payment_info_trade_ins" : "payment_info_form"
    end
  end
  
  def confirm
    if @order.valid? && @order.shipping_address_valid?
      render @order.is_trade_ins? ? "confirm_trade_ins" : "confirm_form"
    else
      render "shipping_info_form"
    end
  end
  
  def create
    if @order.valid? && @order.shipping_address_valid? && current_user.could_order?(@order)
      @order.weight_lb = @order.product.weight_lb

      @order.honey_price = @product.honey_price
      @order.using_condition = @product.using_condition
      begin
        Order.transaction do
          @order.save
          @shipping_stamp = @order.create_new_stamp
        end
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
  
  private

    def set_order_product
      @order = Order.new(params[:order])
      @order.status = Order::STATUES[:pending]
      @order.user = current_user
      @order.shipping_country = "US"
      @product = @order.product = Product.find(params[:order][:product_id])
    end

end
