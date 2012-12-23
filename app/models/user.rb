require 'stripe_gateway'

class User < ActiveRecord::Base
  include StripeGateway
  
  attr_accessible :card_type, :card_name, :card_expired_month, :card_expired_year, :card_last_four_number
  include CardInfo

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :address, 
                  :honey_balance,
                  :stripe_customer_id, :stripe_card_token, :stripe_coupon, :card_number, :card_cvc
  attr_accessible :new_card_number, :new_card_cvc, :new_card_type, :new_card_name, :new_card_expired_month, :new_card_expired_year, :new_card_last_four_number, :new_stripe_card_token

  attr_accessor :new_card_number, :new_card_cvc, :new_card_type, :new_card_name, :new_card_expired_month, :new_card_expired_year, :new_card_last_four_number, :new_stripe_card_token

  has_many :orders, :conditions => "order_type = 1", :order => "status asc, created_at desc"
  has_many :trade_ins, :conditions => "order_type = 0", :class_name => "Order", :order => "status asc, created_at desc"

  validate :validate_card_info
  
  def could_order? order
    order.is_trade_ins? || extra_honey_for(order.product) <= 0
  end
  
  def extra_honey_for product
    return 0 if product.honey_price.nil? || product.honey_price == 0 || (self.honey_balance && self.honey_balance >= product.honey_price)
    return product.honey_price if self.honey_balance.nil?
    return product.honey_price - self.honey_balance 
  end
  
  def payment_ready?
    self.stripe_customer_id && !self.stripe_customer_id.blank?
  end

  private
  
    def validate_card_info
      new_card_info_valid?
      #more checking in there
    end
    
    def new_card_info_valid?
      return true if new_card_name.blank? && new_card_expired_month.blank? && new_card_expired_year.blank?
      
      if new_stripe_card_token.blank? || new_card_last_four_number.blank? || 
          new_card_expired_month.blank? || new_card_expired_year.blank? || new_card_type.blank?
        errors.add(:credit_card, "Invalid credit card")
        return false
      end
      
      begin
        if self.stripe_customer_id && !self.stripe_customer_id.blank? && 
            self.stripe_card_token && self.new_stripe_card_token != self.stripe_card_token
          if update_payment_customer
            self.stripe_customer_id = stripe_customer.id
            self.card_name = self.new_card_name
            self.card_type = self.new_card_type
            self.card_expired_year = self.new_card_expired_year
            self.card_expired_month = self.new_card_expired_month
            self.card_last_four_number = self.new_card_last_four_number
            return true
          end
        end
        
        stripe_customer = create_payment_customer
        self.stripe_customer_id = stripe_customer.id
        self.card_name = self.new_card_name
        self.card_type = self.new_card_type
        self.card_expired_year = self.new_card_expired_year
        self.card_expired_month = self.new_card_expired_month
        self.card_last_four_number = self.new_card_last_four_number
        
        return true
      rescue Exception => e
        if e.message =~ /No such coupon:/
          errors.add(:stripe_coupon, "is invalid: #{e.message}")
        else
          errors.add(:card_number, "is invalid: #{e.message}")
        end
        return false
      end
    end

end
