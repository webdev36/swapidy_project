class ApplicationController < ActionController::Base
  protect_from_forgery
  
  #before_filter :check_uri #deployed on swapidy.com
  before_filter :prepaire_add_honey
  
  #def check_uri
  #  redirect_to request.protocol + "www." + request.host_with_port + request.fullpath if !/^www/.match(request.host) if Rails.env == 'production'
  #end
  
  
  #unless Rails.application.config.consider_all_requests_local
    #rescue_from Exception, :with => :render_not_found
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
    rescue_from ActionController::RoutingError, :with => :render_not_found
    rescue_from ActionController::UnknownController, :with => :render_not_found
    rescue_from ActionController::UnknownAction, :with => :render_not_found
  #end
  
  def require_login
    unless user_signed_in?
      redirect_to new_user_session_path, :flash => { :info => "You must first log in or sign up before accessing this page." }
    end  
  end
  
  def prepaire_add_honey
    #init new payment to add honey
    return unless user_signed_in?
    @payment = PaymentTransaction.new()
    @payment.user = current_user
    @payment.card_type = current_user.card_type
    @payment.card_expired_year = current_user.card_expired_year
    @payment.card_expired_month = current_user.card_expired_month
    @payment.card_name = current_user.card_name
    
    @free_honey = FreeHoney.new if current_user.free_honey_sendable?
  end
  
  def check_to_display_guide
    session[:need_to_display_guide] = true if current_user && current_user.sign_in_count <= 3
  end

  private
    
    def render_not_found
      render '/error_pages/404'
    end

end
