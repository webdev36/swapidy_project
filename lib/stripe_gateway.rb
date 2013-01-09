require "stripe"

module StripeGateway

  STRIPE_PUBLIC_KEY = "pk_live_hb8dw0w3yYHBMRxI2bEF2i9h" #public test key
  STRIPE_SECURE_KEY = "sk_live_EcvSaW2yU5DLgZHKBw718a0X" #public test key

  STRIPE_PLAN_ID = "montly" # a Recurring Payment Plan from Stripe Gateway

  def self.payment_public_key
    STRIPE_PUBLIC_KEY
  end

  # retrieve amount of Recurring Payment Plan from Stripe Gateway
  def self.retrieve_plan_amount logger = nil
    @logger = logger ? logger : Logger.new("log/strip_gateway.log")
    @logger.info "Retrieve plan: #{Stripe.api_key}"
    begin
      Stripe.api_key = STRIPE_PUBLIC_KEY
      plan = Stripe::Plan.retrieve(STRIPE_PLAN_ID)
      return plan.amount.to_i / 100
    rescue Exception => e
      @logger.info "Error: #{e.message}"
      raise e
    end
  end


  # create card token related to the Payment Plan in Stripe.com
  def create_payment_card_token logger = nil
    @logger = logger ? logger : Logger.new("log/strip_gateway.log")
    Stripe.api_key = STRIPE_PUBLIC_KEY
    @logger.info "Public key: #{Stripe.api_key}"
    @logger.info "Card_info: #{self.card_number}"
    begin
      return Stripe::Token.create(
          :card => {
          :number => self.card_number,
          :exp_month => self.card_expired_month,
          :exp_year => self.card_expired_year,
          :cvc => self.card_cvc
        },
        :amount => 1,
        :currency => "usd"
      )
    rescue Stripe::CardError => e
      @logger.info "Card Error: #{e.message}"
      raise e
    rescue Exception => e
      @logger.info "Error: #{e.message}"
      return nil
    end
  end

  # create customer related to the Payment Plan in Stripe.com
  # after created, the customer would be charged at the first day of next month in Pacific Time (US & Canada)
  def create_payment_customer logger = nil
    @logger = logger ? logger : Logger.new("log/strip_gateway.log")
    @logger.info "Create customer: #{self.email}"
    begin
      Stripe.api_key = STRIPE_SECURE_KEY
      customer_params = {:description => self.email, :card => self.new_stripe_card_token}
      return Stripe::Customer.create(customer_params)
    rescue Exception => e
      @logger.info "create_payment_customer - Error: #{e.message}"
      raise e
    end
  end

  # cancel customer related to the Payment Plan in Stripe.com
  # after canceled, the customer information will be remained in Stripe.com, but he/she will not be charged more
  def cancel_payment_customer logger = nil
    @logger = logger ? logger : Logger.new("log/strip_gateway.log")
    @logger.info "Cancel customer: #{self.email}"
    begin
      Stripe.api_key = STRIPE_SECURE_KEY
      cu = Stripe::Customer.retrieve(self.stripe_customer_id) rescue nil
      cu.cancel_subscription if cu
    rescue Exception => e
      return true if e.message == "No such customer: #{self.stripe_customer_id}"
      @logger.info "Error: #{e.message}"
      raise e
    end
  end

  # retrieve customer related to the Payment Plan in Stripe.com
  # if the customer has no plan, he/she will be created and will be charged from next month
  def reactive_payment_customer logger = nil
    @logger = logger ? logger : Logger.new("log/strip_gateway.log")
    @logger.info "Reactive customer: #{self.email}"
    begin
      Stripe.api_key = STRIPE_SECURE_KEY
      cu = Stripe::Customer.retrieve(self.stripe_customer_id) rescue nil
      #cu.create_subscription({:prorate => true, :card => self.stripe_card_token, :plan => STRIPE_PLAN_ID, :trial_end => get_next_trial_time.to_i}) if cu
      cu.update_subscription({:prorate => true, :plan => STRIPE_PLAN_ID, :trial_end => get_next_trial_time.to_i}) if cu
    rescue Exception => e
      @logger.info "Error: #{e.message}"
      raise e
    end
  end

  # update customer payment information (card, plan, description and coupon if he/she has)
  def update_payment_customer(logger = nil)
    @logger = logger ? logger : Logger.new("log/strip_gateway.log")
    @logger.info "Update customer: #{self.email}"
    begin
      Stripe.api_key = STRIPE_SECURE_KEY
      cu = Stripe::Customer.retrieve(self.stripe_customer_id)
      cu.description = self.email
      cu.card = self.new_stripe_card_token
      #cu.plan = STRIPE_PLAN_ID
      #cu.coupon = self.stripe_coupon if self.stripe_coupon && !self.stripe_coupon.blank?
      cu.save
      return true
    rescue Exception => e
      @logger.info "Error: #{e.message}"
      raise e
    end
  end

  # delete customer information from stripe.com
  def delete_payment_customer params, logger = nil
    @logger = logger ? logger : Logger.new("log/strip_gateway.log")
    @logger.info "Delete customer: #{params[:email]}"
    begin
      Stripe.api_key = STRIPE_SECURE_KEY
      cu = Stripe::Customer.retrieve(self.stripe_customer_id)
      cu.delete
    rescue Exception => e
      @logger.info "Error: #{e.message}"
      raise e
    end
  end

  # create payment charge a customer in stripe.com
  def create_payment_charge payment, logger = nil
    @logger = logger ? logger : Logger.new("log/strip_gateway.log")
    @logger.info "Charge customer: #{payment.user.email}"
    begin
      Stripe.api_key = STRIPE_SECURE_KEY
      charge = Stripe::Charge.create(
        :amount => (payment.amount * 100).to_i, # amount in cents
        :currency => "usd",
        :customer => payment.user.stripe_customer_id, #use card_token_id or customer_id
        :description => "Charge for #{payment.honey_money} Honey"
      )
      @logger.info "Payment result: #{charge.to_s}"
      if charge.paid
        @logger.info "Charge Success (#{charge.id})"
        payment.payment_charge_id = charge.id
        #payment.create_at = Time.now #charge.created
        return true
      else
        @logger.info "Charge failure (#{charge.id})"
        return false
      end
    rescue Exception => e
      @logger.info "Charge Error: #{e.message}"
      raise e
    end
  end

  # create refund for a charge
  def create_payment_refund payment, logger = nil
    @logger = logger ? logger : Logger.new("log/strip_gateway.log")
    
    return unless payment && payment.user
    @logger.info "Refund customer: #{payment.user.email}"
    begin
      Stripe.api_key = STRIPE_PUBLIC_KEY
      charge = Stripe::Charge.retrieve(payment.payment_charge_id)
      charge.refund(:amount => (payment.amount*100).to_i) # amount in cents
    rescue Exception => e
      @logger.info "Charge Error: #{e.message}"
      raise e
    end
  end

  def get_payment_charge_id invoice_id, customer, logger = nil
    @logger = logger ? logger : Logger.new("log/strip_gateway.log")
    @logger.info "Get charge for customer: #{customer.email}"
    begin
      Stripe.api_key = STRIPE_PUBLIC_KEY
      charges = Stripe::Charge.all(:customer => customer.stripe_customer_id)
      @logger.info "Charges class: #{charges.class.name}"
      if charges.count > 0
        charges.data.each do |charge|
          return charge.id if charge.invoice == invoice_id
        end
      end
    rescue Exception => e
      @logger.info "Charges Error: #{e.message}"
    end
    return nil
  end
  
end
