class RegistrationsController < Devise::RegistrationsController

  def new
    respond_to do |format|
      format.html {
        redirect_to "/"
      }
    end    
  end

  def create
    session[:signed_in_via_facebook] = nil
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
          redirect_to :controller => :orders, :action => :new, :method => :post
          UserNotifier.signup_greeting(resource).deliver
          #check_to_display_guide
          return
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
          expire_session_data_after_sign_in!
        end
      else
        clean_up_passwords resource
      end
      
      @user_for_register = true
      render "/orders/email_info_form"
    end
  end
  
  def edit
    page_title "Settings"
    resource.new_card_expired_year = resource.card_expired_year
    resource.new_card_expired_month = resource.card_expired_month
    resource.new_card_name = resource.card_name
    unless (resource.card_last_four_number || "").blank?
      resource.new_card_cvc = "xxx"
      resource.new_card_number = "xxxx-xxxx-xxxx-#{resource.card_last_four_number}" 
    end
  end
  
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    if session[:signed_in_via_facebook] || params[:update_credit_card]
      update_result =  resource.update_without_password(resource_params)
    elsif session[:disconnect_facebook]
      update_result =  resource.update_for_disconnect(resource_params)
    else
      update_result =  resource.update_with_password(resource_params)
    end
    if update_result
      if session[:disconnect_facebook]
        session[:disconnect_facebook] = nil
        sign_in(resource_name, resource)
      else
        sign_in resource_name, resource, :bypass => true
      end 
      flash[:update_account_notice] = "Your information has successfully been changed"
      if params[:update_credit_card]
        redirect_to "/users/edit?update_credit_card=true"  
      elsif params[:update_user_settings]
        redirect_to "/users/edit?update_user_settings=true" 
      else
        redirect_to "/users/edit"
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end
  
  def redeem
    @redeem_code = RedeemCode.new(params[:user])
    existed_redeem = @redeem_code.redeemable?
    if existed_redeem
      build_resource
      resource.redeem_code = existed_redeem
      resource.balance_amount = existed_redeem.amount
      resource.save
      UserNotifier.signup_greeting(resource).deliver
      sign_up(resource_name, resource)
      
      receiver_notification = Notification.new(:title => "#{existed_redeem.amount} FREE Money Promo")
      receiver_notification.user = resource
      receiver_notification.description = "#{existed_redeem.amount} FREE Money Redeemed"
      receiver_notification.save
      UserNotifier.redeem_completed(existed_redeem, resource).deliver
    
      check_to_display_guide
      redirect_to "/"
    else
      render "/redeem/index", :layout => "application_with_bg_contain"
    end
  end
end
