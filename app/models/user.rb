require 'stripe_gateway'

class User < ActiveRecord::Base
  include StripeGateway

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :address, 
                  :honey_balance,
                  :card_type, :card_name, :card_expired_month, :card_expired_year, :card_postal_code, :card_last_four_number,
                  :stripe_customer_id, :stripe_card_token, :stripe_coupon, :stripe_customer_card_token, :card_number, :card_cvc
 
  attr_accessor :card_number, :card_cvc
  
  has_many :orders, :conditions => "order_type = 1", :order => "status asc, created_at desc"
  has_many :trade_ins, :conditions => "order_type = 0", :class_name => "Order", :order => "status asc, created_at desc"

  validate :validate_card_info
  
  def self.authenticate_with_password(email, password)
    user = find_by_email(email)
    return user if user && user.encrypted_password == BCrypt::Engine.hash_secret(password)
  end
    
  def card_expired_date
    return "#{self.card_expired_year}-#{self.card_expired_month}-01".to_date rescue nil
  end
  def card_expired_date=(date)
    self.card_expired_month = date.month.to_s
    self.card_expired_year = date.year.to_s
  end
  
  def card_info_valid?
    return if self.card_number.blank? && self.card_name.blank? && self.card_cvc.blank? && self.card_expired_month.blank? && card_expired_year.blank?
    return true if card_token_existed_and_no_change?

    begin
      if self.stripe_customer_card_token && self.stripe_customer_id && self.stripe_customer_card_token != self.stripe_card_token
        update_payment_customer
      elsif self.stripe_customer_id.nil?
        stripe_customer = create_payment_customer
        self.stripe_customer_id = stripe_customer.id
      end
      self.stripe_customer_card_token  = self.stripe_card_token
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
  
  def able_to_buy? product
    return true if extra_honey_for(product) <= 0
    self.stripe_customer_id && !self.stripe_customer_id.blank?
  end
  
  def extra_honey_for product
    return 0 if product.honey_price.nil? || product.honey_price == 0 || (self.honey_balance && self.honey_balance >= product.honey_price)
    return product.honey_price if self.honey_balance.nil?
    return product.honey_price - self.honey_balance 
  end
  

  private
  
    def validate_card_info
      return true unless new_record?
      return card_info_valid?
    end

    def card_token_existed_and_no_change?
      self.stripe_customer_id && self.stripe_customer_card_token && self.stripe_customer_card_token == self.stripe_card_token
    end

end
