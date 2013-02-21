class RedeemCode < ActiveRecord::Base
  attr_accessible :code, :user_id, :expired_date, :amount, :email, :password, :password_confirmation, :status
  
  attr_accessor :email, :password, :password_confirmation
  
  has_many :users
  
  STATUES = {:pending => 0, :completed => 1, :cancelled => 2}
  scope :pending, :conditions => {:status => STATUES[:pending]}
  
  validates :amount, :status, :expired_date, :code, :presence => true
  validates_uniqueness_of :code
  #validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}#, :message => "Invalid email address"
  
  before_validation :generate_fields
  
  def expired?
    Time.now > self.expired_date
  end
  
  def redeemable?
    existed_code = RedeemCode.find_by_code self.code
    unless existed_code
      self.errors.add(:code, "is invalid") 
      return false
    end
    
    if existed_code.expired? || existed_code.status != STATUES[:pending]
      self.errors.add(:code, "has been expired")
      return false
    end

    if User.where(:email => self.email).exists?
      self.errors.add(:email, "has been signed up before")
      return false
    end
    
    new_user = User.new(:email => self.email, :password => self.password, :password_confirmation => self.password_confirmation)
    unless new_user.valid?
      new_user.errors.keys.each do |key|
        self.errors.add(key, new_user.errors[key].last)
      end
      return false
    end    
    return existed_code
  end
  
  def redeem
    user = User.signup_user(:email => email, :password => self.password, :password_confirmation => self.password_confirmation)
    user.balance_amount = (user.balance_amount || 0.00) + self.amount
    user.redeem_code = self
    user.save
    
    receiver_notification = Notification.new(:title => "$#{self.amount} FREE Money Promo")
    receiver_notification.user = user
    receiver_notification.description = "$#{self.amount} FREE Money Redeemed"
    receiver_notification.save
    UserNotifier.redeem_completed(self, user).deliver
    return user
  end
  
  private

    def default_expired_days
      (SwapidySetting.get('REDEEM-DEFAULT_EXPIRED_DAYS') || "7").to_i rescue 7
    end
    def default_money
      (SwapidySetting.get('REDEEM-DEFAULT_MONEY') || "50").to_f rescue 50.00
    end
  
    def generate_fields
      while(self.code.nil? || self.code.blank? || RedeemCode.where("id != ? and code = ?", self.id, self.code).exists? ) do
        number_charset = %w{1 2 3 4 6 7 9}
        string_charset = %w{A C D E F G H J K M N P Q R T V W X Y Z}
        number_code = (1..4).map{ number_charset.to_a[rand(number_charset.size)] }.join("")
        char_code = (1..2).map{ string_charset.to_a[rand(string_charset.size)] }.join("")
        self.code = "SWEETMONEY#{number_code}#{char_code}"
      end
      self.status = STATUES[:pending] unless self.status
      self.expired_date = (DateTime.now + default_expired_days.days) unless self.expired_date
      self.amount = default_money if self.amount.nil? || self.amount == 0.0
    end

end
