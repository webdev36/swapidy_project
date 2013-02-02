class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :check_uri #deployed on swapidy.com
  before_filter :prepaire_add_honey
  before_filter :set_cart_products
  
  def check_uri
    return unless Rails.env == 'production'
    if !/^www/.match(request.host)
      redirect_to request.protocol + "www." + request.host_with_port + request.fullpath 
      #redirect_to "https://www." + request.host_with_port + request.fullpath 
    #elsif !request.ssl?
    #  redirect_to :protocol => "https://"
    end
  end
  
  def page_title(title)
    @page_title = title
  end
  
  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_not_found
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

  #return array of OrderProduct instance
  def set_cart_products
    #for testing only
    session[:cart_products] = {
      :sell => Product.for_sell.limit(3).map{|p| {:product_id => p.id, :price => p.price_for_sell, :using_condition => "Flawless"} }, 
      :buy => Product.for_buy.limit(3).map{|p| {:product_id => p.id, :price => p.price_for_buy, :using_condition => "Flawless"} }
    } unless session[:cart_products]
    #session[:cart_products] = {:sell => [], :buy => []} unless session[:cart_products] 
  end
  
  def clear_cart_products
    session[:cart_products] = nil
  end

  private
    
    def render_not_found
      render '/error_pages/404'
    end

end
