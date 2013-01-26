class RedeemController < ApplicationController
  
  def index
    @redeem_code = RedeemCode.new
  end
  
  def success
    
  end
end
