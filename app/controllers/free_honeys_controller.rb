class FreeHoneysController < ApplicationController
  
  before_filter :require_login

  def create
    emails = params[:emails].split(";") if params[:emails] && !params[:emails].blank?
    emails.each do |email|
      Rails.logger.info "Email: #{email}"
      free_honey = FreeHoney.new(:receiver_email => email)
      free_honey.sender = current_user
      free_honey.save
      if free_honey.valid?
        Rails.logger.info "Valid"
      else
        Rails.logger.info "Error: #{free_honey.errors.full_messages}"
      end
    end
    redirect_to "/"
  end

  def confirm
    @free_honey = FreeHoney.find_by_token_key params[:token]
    if @free_honey && @free_honey.confirm
      #sign_in(@free_honey.receiver)
      session[:token] = params[:token]
      redirect_to "/free_honeys/confirm_complete"
    else
      redirect_to "/free_honeys/invalid_token"
    end
  end
  
  def confirm_complete
    @free_honey = FreeHoney.find_by_token_key session[:token]
    if @free_honey
      render "confirm_success"
    else
      redirect_to "/"
    end
  end
  
  def invalid_token
    
  end

end
