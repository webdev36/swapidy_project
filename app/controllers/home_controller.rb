class HomeController < ApplicationController

  layout 'application_with_slider', :only => [:index]
  ADMIN_EMAILS = %w(adam@swapidy.com pulkit@swapidy.com)

  before_filter :require_login, :only => [:settings]
  
  def index
  end
  
  def transactions
  end
  
  def static_page
    render params[:content]
  end
  
  def contact_us
    unless verify_recaptcha()
      @error_message = "Oh! It's error with reCAPTCHA!"
      return
    end
    
    @contact = params[:contact]
    if @contact.nil? || (@contact[:email] || "").blank? || (@contact[:subject] || "").blank? || (@contact[:message] || "").blank?
      @error_message = "You have to enter all fields!"
      return
    end
    
    unless @contact[:email].match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
      @error_message = "Please enter valid email!"
      return      
    end

    ADMIN_EMAILS.each {|email| UserNotifier.contact_us(email, @contact).deliver }
    flash[:thank_message] = "Thank you for sending contact to us!"

    redirect_to "/contact_us"
  end

end
