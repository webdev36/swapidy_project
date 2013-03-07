class PaymentTransaction < ActiveRecord::Base
  include CardInfo
  
  attr_accessible :card_type, :card_name, :card_expired_month, :card_expired_year, :card_last_four_number
  attr_accessible :payment_invoice_id, :amount, :gateway, :payment_charge_id, :type, :status, :method

  attr_accessible :new_card_number, :new_card_cvc, :new_card_type, :new_card_name, :new_card_expired_month, 
                  :new_card_expired_year, :new_card_last_four_number, :new_stripe_card_token,
                  :stripe_customer_id, :stripe_card_token
  attr_accessor :new_card_number, :new_card_cvc, :new_card_type, :new_card_name, :new_card_expired_month, 
                :new_card_expired_year, :new_card_last_four_number, :new_stripe_card_token,
                :stripe_customer_id, :stripe_card_token

  belongs_to :user
  
  GATEWAY = {:stripe => 0, :braintree => 1}
  TYPES = {:charge => "charge", :refund => "refund"}
  METHODS = {:direct => "direct", :pre_authorize => "pre-authorize"}

  scope :charge, where(:gateway => TYPES[:charge])
  scope :refund, where(:gateway => TYPES[:refund])
  scope :stripe, where(:gateway => GATEWAY[:pre_authorize])
  scope :brantree, where(:gateway => GATEWAY[:brantree])
  scope :pre_authorize, where(:method => METHODS[:pre_authorize])
  scope :direct, where(:method => METHODS[:direct])
  
  validates :amount, :presence => true, :numericality => {:greater_than => 0.0}
  
  def payment_valid?
    unless self.user.payment_ready? || self.new_card_info
      self.errors.add(:new_card_name, "Your account has not registered any Credit Card for payment")
      return false
    end
    return true
  end
  
  def direct_method?
    self.method && self.method == METHODS[:direct]
  end
  def pre_authorize_method?
    self.method && self.method == METHODS[:pre_authorize]
  end
  
end
