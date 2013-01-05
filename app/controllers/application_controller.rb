class ApplicationController < ActionController::Base
  protect_from_forgery
  
  #before_filter :check_uri #deployed on swapidy.com

  #def check_uri
  #  redirect_to request.protocol + "www." + request.host_with_port + request.fullpath if !/^www/.match(request.host) if Rails.env == 'production'
  #end
    
  def require_login
    unless user_signed_in?
      redirect_to new_user_session_path, :flash => { :info => "You must first log in or sign up before accessing this page." }
    end
  end
end
