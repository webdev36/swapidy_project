class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :check_uri

  def check_uri
    if Rails.env.production?
      redirect_to request.protocol + "www." + request.host_with_port + request.request_uri if !/^www/.match(request.host)
    end
  end
  
  def require_login
    unless user_signed_in?
      redirect_to new_user_session_path, :flash => { :info => "You must first log in or sign up before accessing this page." }
    end
  end
end
