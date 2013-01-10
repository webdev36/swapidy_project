class RedeemController < ApplicationController
  
  def index
    @redeem_code = RedeemCode.new
  end
  
  def confirm
    Rails.logger.info "Create here: #{params[:redeem_code]}"
    @redeem_code = RedeemCode.new(params[:redeem_code])
    
    has_error = false
    @redeem_code.errors.add(:code, "could not be blank") if @redeem_code.code.nil? || @redeem_code.code.blank?
    @redeem_code.errors.add(:email, "could not be blank")  if @redeem_code.email.nil? || @redeem_code.email.blank?
    unless @redeem_code.errors.full_messages.empty?
      render "index"
      return
    end
    
    Rails.logger.info "Create here 2"
    redeem_code = RedeemCode.find_by_code @redeem_code.code
    unless redeem_code
      @redeem_code.errors.add(:code, "is invalid value")
      render "index"
      return
    end 
    Rails.logger.info "Create here 3"
    
    @redeem_code = redeem_code
    @redeem_code.email = params[:redeem_code][:email]
    if @redeem_code.redeemable? && @redeem_code.redeem
      Rails.logger.info "Create here 4"
      redirect_to "/redeem/success"
    else
      Rails.logger.info "Create here 5" if @redeem_code.redeemable?
      render "index"
    end
  end
  
  def success
    
  end
end
