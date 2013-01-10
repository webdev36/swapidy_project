class RedeemCode < ActiveRecord::Base
  attr_accessible :code, :user_id, :expired_date, :honey_amount, :email, :status
  
  attr_accessor :email
  
  has_many :users
  
  STATUES = {:pending => 0, :completed => 1, :cancelled => 2}
  scope :pending, :conditions => {:status => STATUES[:pending]}
  
  validates :honey_amount, :status, :expired_date, :code, :presence => true
  validates_uniqueness_of :code
  #validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}#, :message => "Invalid email address"
  
  before_validation :generate_fields
  
  def expired?
    Time.now > self.expired_date
  end
  
  def redeemable?
    errors.add(:email, "could not be blank") if self.email.nil? || self.email.blank?
    return false unless errors.empty?
    
    if self.status != STATUES[:pending]
      errors.add(:email, "Code has been used before")
      return false
    end
    if expired?
      errors.add(:code, "is expired")
      return false
    end
    if User.where(:email => self.email).exists?
      errors.add(:email, "has signed up before")
      return false
    end
    return true
  end
  
  def redeem
    user = User.signup_user(:email => email)
    user.honey_balance = (user.honey_balance || 0.00) + self.honey_amount
    user.redeem_code = self
    user.save
    
    receiver_notification = Notification.new(:title => "Free #{self.honey_amount} Honey Received")
    receiver_notification.user = user
    receiver_notification.description = "Free #{self.honey_amount} Honey receipted"
    receiver_notification.save
    UserNotifier.redeem_completed(self, user).deliver
    return true
  end
  
  private

    def default_expired_days
      SwapidySetting.get('REDEEM-DEFAULT_EXPIRED_DAYS') rescue 7
    end
    def default_honey
      SwapidySetting.get('REDEEM-DEFAULT_HONEY') rescue 50.00
    end
  
    def generate_fields
      while(self.code.nil? || self.code.blank? || RedeemCode.where("id != ? and code = ?", self.id, self.code).exists? ) do
        number_charset = %w{1 2 3 4 6 7 9}
        string_charset = %w{A C D E F G H J K M N P Q R T V W X Y Z}
        number_code = (1..4).map{ number_charset.to_a[rand(number_charset.size)] }.join("")
        char_code = (1..2).map{ string_charset.to_a[rand(string_charset.size)] }.join("")
        self.code = "SWEETHONEY#{number_code}#{char_code}"
      end
      self.status = STATUES[:pending] unless self.status
      self.expired_date = (DateTime.now + default_expired_days.days) unless self.expired_date
      self.honey_amount = default_honey if self.honey_amount.nil? || self.honey_amount == 0.0
    end

end
