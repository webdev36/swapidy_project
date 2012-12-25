class SessionsController < Devise::SessionsController
  
  def create
    if(params[:login_to_order].nil? || params[:login_to_order].blank?)
      super
    else
      self.resource = User.find_by_email params[:user][:email]
      if self.resource && self.resource.valid_password?(params[:user][:password])
        set_flash_message(:notice, :signed_in) if is_navigational_format?
        sign_in(resource_name, resource)
      end

      if user_signed_in?
        redirect_to :controller => :orders, :action => :new, :method => :post, :product_id => params[:product_id], :order_type => params[:order_type]
      else
        @signin_failure = true
        @order = Order.new(:order_type => params[:order_type])
        @product = Product.find params[:product_id]
        render "/orders/email_info_form"
      end
    end
  end

end