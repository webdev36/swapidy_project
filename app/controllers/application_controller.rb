class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  
  before_filter :check_uri #deployed on swapidy.com
  before_filter :prepaire_add_money
  before_filter :check_browsers
  def check_uri
    #clear_cart_products
    return unless Rails.env == 'production'
    return unless ENV['SWAPIDY_VERSION'] && ENV['SWAPIDY_VERSION'] == "swapidy"
    
    if !/^www/.match(request.host)
      redirect_to "https://www." + request.host_with_port + request.fullpath 
    elsif !request.ssl?
      redirect_to :protocol => "https://"
    end
  end
  
  def page_title(title)
    @page_title = title
  end
  
  unless Rails.application.config.consider_all_requests_local
    #rescue_from Exception, :with => :render_not_found
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
    rescue_from ActionController::RoutingError, :with => :render_not_found
    rescue_from ActionController::UnknownController, :with => :render_not_found
    rescue_from ActionController::UnknownAction, :with => :render_not_found
  end
  
  def require_login
    unless user_signed_in?
      redirect_to "/", :flash => { :info => "You must first log in or sign up before accessing this page." }
    end  
  end
  
  def prepaire_add_money
    ShoppingCart.session = session    
    #init new payment to add money
    return unless user_signed_in?
    @free_money = FreeHoney.new if current_user.free_money_sendable?
  end
  
  def check_to_display_guide
    session[:need_to_display_guide] = true if current_user && current_user.sign_in_count <= 3
  end
  
  def check_browsers
    user_agent =request.env['HTTP_USER_AGENT'].downcase
    if user_agent =~ /msie/i
      render :action => 'support_browsers'
    end
  end

  private
    
    def render_not_found
      render '/error_pages/404'
    end

end
