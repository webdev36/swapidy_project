class PaymentsController < ApplicationController
  
  before_filter :require_login
  
  RATIO = 10
  
  def show
    @payment = PaymentTransaction.find params[:id]
  end

  def new
    @payment = PaymentTransaction.new(params[:payment]) rescue PaymentTransaction.new
    @payment.amount = params[:payment][:amount].gsub(",", "").to_i rescue nil
    respond_to do |format|
      format.js {
        @return_content = render_to_string(:partial => "/payments/add_honey_form")
      }
    end
  end
  
  def edit_card
    @payment = PaymentTransaction.new(params[:payment])
    @payment.amount = params[:payment][:amount].gsub(",", "").to_i rescue nil
    
    if(@payment.amount.nil? || @payment.amount <= 0)
      respond_to do |format|
        format.js {
          @return_content = render_to_string(:partial => "/payments/add_honey_form")
        }
      end
      return
    end
    
    unless @payment.has_card_info?
      @payment.card_type = current_user.card_type
      @payment.card_expired_year = current_user.card_expired_year
      @payment.card_expired_month = current_user.card_expired_month
      @payment.card_name = current_user.card_name
      @payment.card_last_four_number = current_user.card_last_four_number
    end
    unless @payment.new_card_info
      @payment.new_card_expired_year = current_user.card_expired_year
      @payment.new_card_expired_month = current_user.card_expired_month
      @payment.new_card_name = current_user.card_name
      unless (current_user.card_last_four_number || "").blank?
        @payment.new_card_number = "xxxx-xxxx-xxxx-#{current_user.card_last_four_number}"
        @payment.new_card_cvc = "xxx"
      end
    end
    
    respond_to do |format|
      format.js {
        @return_content = render_to_string(:partial => "/payments/edit_card_form")
      }
    end
  end
  
  def confirm
    @payment = PaymentTransaction.new(params[:payment])
    @payment.amount = params[:payment][:amount].gsub(",", "").to_i rescue nil

    @payment.user = current_user
    if @payment.valid? && @payment.payment_valid?
      @return_content = render_to_string(:partial => "/payments/confirm")
    else
      Rails.logger.info @payment.errors.full_messages
      @return_content = render_to_string(:partial => "/payments/edit_card_form")
    end
  end
  
  def create
    @payment = PaymentTransaction.new(params[:payment])
    @payment.amount = params[:payment][:amount].gsub(",", "").to_i rescue nil
    @payment.user = current_user
    
    unless (@payment.new_stripe_card_token || "").blank? && @payment.new_card_name == @payment.card_name && 
           @payment.new_card_expired_month == @payment.card_expired_month && 
           @payment.new_card_expired_year == @payment.card_expired_year && 
           @payment.new_card_number == "xxxx-xxxx-xxxx-#{@payment.card_last_four_number}"
      current_user.new_card_name = @payment.new_card_name
      current_user.new_card_expired_month = @payment.new_card_expired_month
      current_user.new_card_expired_year = @payment.new_card_expired_year
      current_user.new_stripe_card_token = @payment.new_stripe_card_token
      current_user.new_card_type = @payment.new_card_type
      current_user.new_card_last_four_number = @payment.new_card_last_four_number
    end

    begin
      PaymentTransaction.transaction do
        current_user.balance_amount = (current_user.balance_amount || 0) + @payment.balance_amount
        unless current_user.save
          @payment.errors.add(:card, "is not valid")
          respond_to do |format|
            format.js {
              @return_content = render_to_string(:partial => "/payments/edit_card_form")
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
        
          #Notification.purchase_honey_notify(@payment)
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
              @return_content = render_to_string(:partial => "/payments/edit_card_form")
            }
          end
          return
        end
      end
    rescue Exception => e
      @payment.errors.add(:payment, e.message)
      Rails.logger.info @payment.errors.full_messages
      
      respond_to do |format|
        format.js {
          @return_content = render_to_string(:partial => "/payments/edit_card_form")
        }
      end
      #render "/payments/new"
    end
  end

end
