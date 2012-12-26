class RegistrationsController < Devise::RegistrationsController

  def create
    if(params[:login_to_order].nil? || params[:login_to_order].blank?)
      super
      UserNotifier.signup_greeting(resource).deliver
    else
      build_resource
      if resource.save
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_navigational_format?
          sign_in(resource_name, resource)
          redirect_to :controller => :orders, :action => :new, :method => :post, :product_id => params[:product_id], :order_type => params[:order_type]
          UserNotifier.signup_greeting(resource).deliver
          return
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
          expire_session_data_after_sign_in!
        end
      else
        clean_up_passwords resource
      end
      
      @user_for_register = true
      @order = Order.new(:order_type => params[:order_type])
      @product = Product.find params[:product_id]
      render "/orders/email_info_form"
    end
  end
  
end