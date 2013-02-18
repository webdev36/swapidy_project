class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def facebook
    if env["omniauth.auth"].present?
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
  
      if @user
        session[:signed_in_via_facebook] = true
        if session[:cart_products]
          sign_in @user, :event => :authentication #this will throw if @user is not activated
          redirect_to :controller => "/orders", :action => :new, :method => :post
        else
          #sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
          sign_in @user, :event => :authentication
          redirect_to :back
          check_to_display_guide
        end
        set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      else
        session[:signed_in_via_facebook] = nil
        session["devise.facebook_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    else
      render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
    end
  end

end