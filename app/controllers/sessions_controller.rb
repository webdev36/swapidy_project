class SessionsController < Devise::SessionsController
  
  def create
    if(params[:login_to_order].nil? || params[:login_to_order].blank?)
      super
    else
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      
      redirect_to :controller => :orders, :action => :new, :method => :post, :product_id => params[:product_id], :order_type => params[:order_type]
    end
  end

end