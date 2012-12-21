class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def require_login
    unless user_signed_in?
      redirect_to new_user_session_path, :flash => { :info => "You must first log in or sign up before accessing this page." }
    end
  end
end
