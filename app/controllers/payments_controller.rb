class PaymentsController < ApplicationController
  
  before_filter :require_login
  before_filter :payment_ready?
  
  RATIO = 10
  
  def show
    @payment = PaymentTransaction.find params[:id]
  end
  
  def new
    @payment = PaymentTransaction.new()
    @payment.user = current_user
  end
  
  def confirm
    @payment = PaymentTransaction.new()
    @payment.honey_money = params[:payment][:honey_money].gsub(",", "").to_i rescue nil
    if @payment.valid? 
      @payment.amount = @payment.honey_money / RATIO
      @payment.user = current_user
      render "confirm"
    else
      render "new"
    end
  end
  
  def create
    @payment = PaymentTransaction.new()
    @payment.honey_money = params[:payment][:honey_money].gsub(",", "").to_i rescue nil
    @payment.amount = @payment.honey_money / RATIO
    @payment.user = current_user

    if current_user.create_payment_charge(@payment)
      @payment.card_type = current_user.card_type
      @payment.card_expired_year = current_user.card_expired_year
      @payment.card_expired_month = current_user.card_expired_month
      @payment.card_name = current_user.card_name
      @payment.card_last_four_number = current_user.card_last_four_number
      @payment.save
      current_user.update_attribute(:honey_balance, (current_user.honey_balance || 0) + @payment.honey_money)
      UserNotifier.honey_purchase(@payment).deliver
      redirect_to "/payments/#{@payment.id}"
    else
      flash[:error] = "Failure to charge the credit card"
      render "/payments/new"
    end
  end
  
  private
    
    def payment_ready?
      unless current_user.payment_ready?
        flash[:error] = "Your payment has not verified. Please edit Credit Card information to continue."
        redirect_to "/users/edit#card_info_container"
      end
    end

end
