class PaymentsController < ApplicationController
  
  before_filter :require_login
  
  def new
    @payment = PaymentTransaction.new(current_user.card_info_in_hash)    
  end
    
end
