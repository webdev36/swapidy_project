class PaymentsController < ApplicationController
  
  before_filter :require_login
  
  RATIO = 10
  
  def show
    @payment = PaymentTransaction.find params[:id]
  end
  
  def new
  end
  
  def edit_card
    @payment = PaymentTransaction.new(params[:payment])
    @payment.amount = params[:payment][:amount].gsub(",", "").to_i rescue nil
    @payment.honey_money = params[:payment][:honey_money].gsub(",", "").to_i rescue nil
    
    if(@payment.honey_money != @payment.amount * RATIO)
      respond_to do |format|
        format.js {
          @return_content = render_to_string(:partial => "/payments/add_honey_form")
        }
      end
      return
    end

    @payment.card_type = current_user.card_type
    @payment.card_expired_year = current_user.card_expired_year
    @payment.card_expired_month = current_user.card_expired_month
    @payment.card_name = current_user.card_name
    @payment.card_last_four_number = current_user.card_last_four_number
    respond_to do |format|
      format.js {
        @return_content = render_to_string(:partial => "/payments/edit_card_form")
      }
    end
  end
  
  def confirm
    @payment = PaymentTransaction.new(params[:payment])
    @payment.amount = params[:payment][:amount].gsub(",", "").to_i rescue nil
    @payment.honey_money = params[:payment][:honey_money].gsub(",", "").to_i rescue nil
    
    @payment.user = current_user
    if @payment.valid? && @payment.payment_valid?
      Rails.logger.info @payment.errors.full_messages
      @return_content = render_to_string(:partial => "/payments/confirm")
    else
      Rails.logger.info @payment.errors.full_messages
      @return_content = render_to_string(:partial => "/payments/edit_card_form")
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
          respond_to do |format|
            format.js {
              @return_content = render_to_string(:partial => "/payments/add_honey_form")
            }
          end
          #render "/payments/new"
          return
        end
        
        if current_user.create_payment_charge(@payment)
          @payment.card_type = current_user.card_type
          @payment.card_expired_year = current_user.card_expired_year
          @payment.card_expired_month = current_user.card_expired_month
          @payment.card_name = current_user.card_name
          @payment.card_last_four_number = current_user.card_last_four_number
          raise "Error to save transaction" unless @payment.save
        
          Notification.purchase_honey_notify(@payment)
          #redirect_to "/payments/#{@payment.id}"
          respond_to do |format|
            format.js {
              @return_content = render_to_string(:partial => "/payments/show")
            }
          end
          return
        else
          @payment.errors.add(:payment, "has failure to charge the credit card")
          #render "/payments/new"
          respond_to do |format|
            format.js {
              @return_content = render_to_string(:partial => "/payments/add_honey_form")
            }
          end
          return
        end
      end
    rescue Exception => e
      @payment.errors.add(:payment, e.message)
      render "/payments/new"
    end
  end

end
