require 'stripe_gateway'

class User < ActiveRecord::Base
  include StripeGateway

  devise :omniauthable
  
  attr_accessible :card_type, :card_name, :card_expired_month, :card_expired_year, :card_last_four_number, :provider_image, :is_admin
  include CardInfo

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :address, 
                  :honey_balance, :sign_in_count,
                  :stripe_customer_id, :stripe_card_token, :stripe_coupon, :card_number, :card_cvc
  attr_accessible :new_card_number, :new_card_cvc, :new_card_type, :new_card_name, :new_card_expired_month, :new_card_expired_year, :new_card_last_four_number, :new_stripe_card_token

  attr_accessor :new_card_number, :new_card_cvc, :new_card_type, :new_card_name, :new_card_expired_month, :new_card_expired_year, :new_card_last_four_number, :new_stripe_card_token

  has_many :orders, :order => "status asc, created_at desc"
  has_many :user_providers
  
  has_many :notifications, :order => "created_at desc, updated_at desc"
  has_many :free_honey_invitations, :foreign_key => "sender_id", :class_name => "FreeHoney", :order => "created_at desc, updated_at desc"

  validate :validate_card_info
  
  belongs_to :redeem_code
  
  def full_name
    name = [first_name, last_name].compact.join(" ").strip
    return name.blank? ? "PROFILE" : name
  end
  
  def name_in_email
    return first_name.humanize if first_name && !first_name.blank?
    return last_name.humanize if last_name && !last_name.blank?
    ""
  end
  
  def self.signup_user user_attributes
    user = User.new(user_attributes)
    if user.password.nil? || user.password.blank?
      user.password = user.password_confirmation = Devise.friendly_token[0,8]
    end  
    user.save
    UserNotifier.signup_greeting(user).deliver
    return user
  end
  
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.find_by_email(auth.info.email)
    user = UserProvider.where(:provider => auth.provider, :uid => auth.uid).first.try(:user) unless user
    
    unless user
      user = signup_user(:first_name => auth.extra.raw_info.first_name,
                         :last_name => auth.extra.raw_info.last_name,
                         :email => auth.info.email,
                         :address => auth.info.location,
                         :provider_image => auth.info.image)  
    end
    
    provider_attributes = { provider: auth.provider, uid: auth.uid, access_token: auth.credentials.token, token_expires_at: (Time.at(auth.credentials.expires_at) rescue nil) }
    if user.user_providers.facebook.first.present?
      user.user_providers.facebook.first.update_attributes provider_attributes
    else
      user.user_providers.build(provider_attributes)
      
      user.first_name = auth.extra.raw_info.first_name if (user.first_name || "").blank?
      user.last_name = auth.extra.raw_info.last_name if (user.last_name || "").blank?
      user.address = auth.info.location if (user.address || "").blank?
      user.provider_image = auth.info.image if (user.provider_image || "").blank?
      user.save
    end
    return user
  end

  
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
  
  def is_admin?
    is_admin
  end
  
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
  
  def last_order(order_type = Order::TYPES[:order])
    last_same_order = (order_type == Order::TYPES[:order]) ? self.orders.to_buy.last : self.orders.to_sell.last
    return last_same_order if last_same_order
    return self.orders.last
  end
  
  def has_same_order?(order_type = Order::TYPES[:order])
    (order_type == Order::TYPES[:order]) ? self.orders.to_buy.exists? : self.orders.to_sell.exists?
  end
  
  def remain_inviation_count
    if self.free_honey_invitations.count < FreeHoney::MAX_COUNT
      return FreeHoney::MAX_COUNT - self.free_honey_invitations.count
    else
      return 0
    end
  end
  
  def free_honey_sendable?
    remain_inviation_count > 0 && self.created_at > 7.days.ago
  end
  

end
