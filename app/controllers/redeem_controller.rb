class RedeemController < ApplicationController
  
  layout "application_with_bg_contain"

  def index
    @redeem_code = RedeemCode.new
  end
  
  def success
    
  end
end
