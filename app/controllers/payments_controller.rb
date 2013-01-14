class PaymentsController < ApplicationController
  
  before_filter :require_login
  
  RATIO = 10
  
  def show
    @payment = PaymentTransaction.find params[:id]
  end
  
  def new
  end
  
  def confirm
    @payment = PaymentTransaction.new(params[:payment])
    @payment.amount = params[:payment][:amount].gsub(",", "").to_i rescue nil
    @payment.honey_money = @payment.amount * RATIO

    @payment.card_type = current_user.card_type
    @payment.card_expired_year = current_user.card_expired_year
    @payment.card_expired_month = current_user.card_expired_month
    @payment.card_name = current_user.card_name
    @payment.card_last_four_number = current_user.card_last_four_number

    @payment.user = current_user
    if @payment.valid? && @payment.payment_valid?
      render "confirm"
    else
      render "new"
    end
  end
  
  def create
    @payment = PaymentTransaction.new(params[:payment])
    @payment.amount = params[:payment][:amount].gsub(",", "").to_i rescue nil
    @payment.honey_money = @payment.amount * RATIO
    @payment.user = current_user
    
    current_user.new_card_name = @payment.new_card_name
    current_user.new_card_expired_month = @payment.new_card_expired_month
    current_user.new_card_expired_year = @payment.new_card_expired_year
    current_user.new_stripe_card_token = @payment.new_stripe_card_token
    current_user.new_card_type = @payment.new_card_type
    current_user.new_card_last_four_number = @payment.new_card_last_four_number
    
    begin
      PaymentTransaction.transaction do
        current_user.honey_balance = (current_user.honey_balance || 0) + @payment.honey_money
        unless current_user.save
          @payment.errors.add(:card, "is not valid")
          render "/payments/new"
        end
        
        if current_user.create_payment_charge(@payment)
          @payment.card_type = current_user.card_type
          @payment.card_expired_year = current_user.card_expired_year
          @payment.card_expired_month = current_user.card_expired_month
          @payment.card_name = current_user.card_name
          @payment.card_last_four_number = current_user.card_last_four_number
          raise "Error to save transaction" unless @payment.save
        
          Notification.purchase_honey_notify(@payment)
          redirect_to "/payments/#{@payment.id}"
          return
        else
          @payment.errors.add(:payment, "has failure to charge the credit card")
          render "/payments/new"
        end
      end
    rescue Exception => e
      @payment.errors.add(:payment, e.message)
      render "/payments/new"
    end
  end

end
