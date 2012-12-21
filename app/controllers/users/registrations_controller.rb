class Users::RegistrationsController < Devise::RegistrationsController

  def create
    if(params[:login_to_order].nil? || params[:login_to_order].blank?)
      super
    else
      build_resource
      if resource.save
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_navigational_format?
          sign_up(resource_name, resource)
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
          expire_session_data_after_sign_in!
        end
      else
        clean_up_passwords resource
      end
    
      redirect_to :controller => :orders, :action => :new, :method => :post, :product_id => params[:product_id], :order_type => params[:order_type]
    end
    
  end
  
end