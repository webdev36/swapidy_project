class RedeemController < ApplicationController
  
  def index
    @redeem_code = RedeemCode.new
  end
  
  def create
    @redeem_code = RedeemCode.new(params[:redeem_code])
    
    @redeem_code.errors.add(:code, "could not be blank") if @redeem_code.code.nil? || @redeem_code.code.blank?
    @redeem_code.errors.add(:email, "could not be blank") if @redeem_code.email.nil? || @redeem_code.email.blank?
    unless @redeem_code.errors.full_messages.empty?
      render "index"
      return
    end
    
    redeem_code = RedeemCode.find_by_code @redeem_code.code
    unless redeem_code
      @redeem_code.errors.add(:code, "is invalid value")
      render "index"
      return
    end 
    
    @redeem_code = redeem_code
    redeem_code.email = @redeem_code.email

    if redeem_code.redeemable? && redeem_code.redeem
      redirect_to "/redeem/success"
    else
      redeem_code.errors.each{|error| @redeem_code.errors.add(error) }
      render "index"
    end
  end
  
  def success
    
  end
end
