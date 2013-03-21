require 'stripe_gateway'

class User < ActiveRecord::Base
  include StripeGateway

  devise :omniauthable
  
  attr_accessible :card_type, :card_name, :card_expired_month, :card_expired_year, :card_last_four_number, :provider_image, :is_admin
  include CardInfo

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :address, 
                  :balance_amount, :sign_in_count,
                  :stripe_customer_id, :stripe_card_token, :stripe_coupon, :card_number, :card_cvc
  attr_accessible :code, :new_card_number, :new_card_cvc, :new_card_type, :new_card_name, :new_card_expired_month, :new_card_expired_year, :new_card_last_four_number, :new_stripe_card_token

  attr_accessible :paypal_email
  
  attr_accessor :code, :new_card_number, :new_card_cvc, :new_card_type, :new_card_name, :new_card_expired_month, :new_card_expired_year, :new_card_last_four_number, :new_stripe_card_token

  has_many :orders, :order => "created_at desc, status asc"
  has_many :user_providers
  has_many :payments, :class_name => "PaymentTransaction", :order => "created_at desc, updated_at desc"

  
  has_many :notifications, :order => "created_at desc, updated_at desc"
  has_many :free_money_invitations, :foreign_key => "sender_id", :class_name => "FreeHoney", :order => "created_at desc, updated_at desc"

  validate :validate_card_info
  
  belongs_to :redeem_code
  
  def full_name
    name = [first_name, last_name].compact.join(" ").strip
    return name.blank? ? "MY ACTIVITY" : name
  end
  
  def blank_name?
    [first_name, last_name].compact.join(" ").strip.blank?
  end
  
  def name_in_email
    return first_name.humanize if first_name && !first_name.blank?
    return last_name.humanize if last_name && !last_name.blank?
    ""
  end
  
  def self.signup_user user_attributes, mode = :normal_signup
    user = User.new(user_attributes)
    if user.password.nil? || user.password.blank?
      user.password = user.password_confirmation = Devise.friendly_token[0,8]
    end  
    user.save
    UserNotifier.signup_greeting(user, mode).deliver
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

  
  def could_order? amount
    amount <= 0 || extra_money_for(amount) <= 0 || has_card_info?
  end
  
  def extra_money_for amount
    return 0 if amount.nil? || amount == 0 || (self.balance_amount && self.balance_amount.to_i >= amount)
    return amount if self.balance_amount.nil?
    return amount - self.balance_amount 
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
    return true unless self.new_card_info
    
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
  
  def last_order
    return self.orders.limit(1).first
  end
  
  def remain_inviation_count
    if self.free_money_invitations.count < FreeHoney::MAX_COUNT
      return FreeHoney::MAX_COUNT - self.free_money_invitations.count
    else
      return 0
    end
  end
  
  def free_money_sendable?
    remain_inviation_count > 0 && self.created_at > 7.days.ago
  end
  
  # def update_for_disconnect(params, *options)
    # result = update_attributes(params, *options)
    # result
  # end
  def update_for_disconnect(params, *options)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    update_attributes(params, *options)
    self.assign_attributes(params, *options)
    return self.valid?
  end

end
