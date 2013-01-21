class RegistrationsController < Devise::RegistrationsController

  def create
    if(params[:login_to_order].nil? || params[:login_to_order].blank?)
      build_resource

      #optimize codes from Devise action
      if resource.save
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_navigational_format?
          sign_up(resource_name, resource)
          #respond_with resource, :location => after_sign_up_path_for(resource)
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
          expire_session_data_after_sign_in!
          @return_content = render_to_string(:partial => "/devise/shared/signup_form", :locals => {:show_cancel_link => true})
          #respond_with resource, :location => after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        #respond_with resource
        @return_content = render_to_string(:partial => "/devise/shared/signup_form", :locals => {:show_cancel_link => true})
      end
      if user_signed_in?
        UserNotifier.signup_greeting(resource).deliver
        check_to_display_guide
      end
    else
      build_resource
      if resource.save
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_navigational_format?
          sign_in(resource_name, resource)
          redirect_to :controller => :orders, :action => :new, :method => :post, :product_id => params[:product_id], :using_condition => params[:using_condition], :order_type => params[:order_type]
          UserNotifier.signup_greeting(resource).deliver
          check_to_display_guide
          return
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
          expire_session_data_after_sign_in!
        end
      else
        clean_up_passwords resource
      end
      
      @user_for_register = true
      @order = Order.new(:order_type => params[:order_type], :using_condition => params[:using_condition])
      @product = Product.find params[:product_id]
      render "/orders/email_info_form"
    end
  end
  
  def edit
    resource.new_card_expired_year = resource.card_expired_year
    resource.new_card_expired_month = resource.card_expired_month
    resource.new_card_name = resource.card_name
    resource.new_card_number = "xxxx-xxxx-xxxx-#{resource.card_last_four_number}" unless (resource.card_last_four_number || "").blank?
  end
  
end