class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def facebook
    if env["omniauth.auth"].present?
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
  
      if @user
        if session[:creating_order]
          session[:return_to] = "/orders/new?product_id=#{session[:creating_order][:product_id]}&using_condition=#{session[:creating_order][:using_condition]}&order_type=#{session[:creating_order][:order_type]}"
          sign_in @user, :event => :authentication #this will throw if @user is not activated
          redirect_to :controller => "/orders", :action => :new, :method => :post, :product_id => session[:creating_order][:product_id], :using_condition => session[:creating_order][:using_condition], :order_type => session[:creating_order][:order_type]
        else
          sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        end
        set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
        check_to_display_guide
      else
        session["devise.facebook_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    else
      render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
    end
  end
  
  def login user
    self.current_user = user
  end

end