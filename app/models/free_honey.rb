class FreeHoney < ActiveRecord::Base
  attr_accessible :completed_at, :receiver_email, :expired_date, :sender_honey_amount, :receiver_honey_amount, :status, :token_key, :receiver_id, :sender_id
  
  belongs_to :receiver, :foreign_key => "receiver_id", :class_name => "User"
  belongs_to :sender, :foreign_key => "sender_id", :class_name => "User"
   
  STATUES = {:pending => 0, :completed => 1, :declined => 2, :cancelled => 3}
  validates :receiver_honey_amount, :status, :expired_date, :token_key, :presence => true
  validates :receiver_email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}#, :message => "Invalid email address"
  validate :user_with_right_email?
  
  before_validation :check_receiver_email
  before_validation :generate_token_key
  after_create :create_notifications
  
  MAX_COUNT = 3
  
  scope :pending, :conditions => {:status => STATUES[:pending]}
  
  def expired?
    Time.now > self.expired_date
  end
  
  def able_to_send?
    retun false unless valid?
    
  end
  
  def able_to_confirm?
    return false unless self.status == STATUES[:pending] && !expired?
    if receiver.nil? && User.where(:email => self.receiver_email).exists?
      errors.add(:receiver_email, "has signed up in system before")
      return false
    end
    return true
  end
  
  def confirm
    return false unless able_to_confirm?
    if self.receiver.nil?
      self.receiver = User.signup_user(:email => self.receiver_email)
    end
    self.status = STATUES[:completed] 
    self.sender_honey_amount = default_reward_honey
    self.completed_at = Time.now
    self.save

    self.receiver.update_attribute(:honey_balance, (self.receiver.honey_balance || 0.00) + self.receiver_honey_amount)
    receiver_notification = Notification.new(:title => "Free #{self.receiver_honey_amount} Honey Received")
    receiver_notification.user = self.receiver
    receiver_notification.description = "Free #{self.receiver_honey_amount} Honey receipted"
    receiver_notification.save
    UserNotifier.free_honey_completed(self).deliver

    #create_reward_and_bonus
    if self.sender
      self.sender.update_attribute(:honey_balance, (self.sender.honey_balance || 0.00) + self.sender_honey_amount)
      sender_notification = Notification.new(:title => "Free Honey Reward")
      sender_notification.user = self.sender
      sender_notification.description = "Free #{self.sender_honey_amount} Honey Reward: #{receiver_title} accepted your invitation}"
      sender_notification.save
      UserNotifier.free_honey_reward(self).deliver 
    end
    
    other_free_honey = FreeHoney.pending.where(:receiver_email => self.receiver_email).where("id != #{self.id}").each do |other_one|
      other_one.update_attribute(:status => STATUES[:cancelled])
    end
    return true
  end
  
  def receiver_title
    receiver ? "#{receiver.full_name} <#{receiver.email}>" : receiver_email
  end
  
  def sender_title
    sender ? "#{sender.full_name} <#{sender.email}>" : "Swapidy"
  end
    
  def create_notifications
    if sender
      sender_notification = Notification.new(:title => "Free Honey Sent")
      sender_notification.user = self.sender
      sender_notification.description = "Free Honey: sent to #{receiver_title} at #{self.created_at.strftime("%b %d, %Y")}"
      sender_notification.save
    end
    
    if receiver
      receiver_notification = Notification.new(:title => "Free #{self.receiver_honey_amount} Honey Invitation")
      receiver_notification.user = self.receiver
      receiver_notification.description = "Free #{self.receiver_honey_amount} Honey: sent from #{sender_title}"
      receiver_notification.save
    end
    UserNotifier.free_honey_sent(self).deliver
  end

  private
  
    def default_expired_days
      SwapidySetting.get('FREE_HONEY-DEFAULT_EXPIRED_DAYS') rescue 7
    end
    
    def default_reward_honey  
      SwapidySetting.get('FREE_HONEY-DEFAULT_REWARD_HONEY') rescue 100.0
    end
    
    def default_receiver_honey
      SwapidySetting.get('FREE_HONEY-DEFAULT_RECEIVER_HONEY') rescue 50.0
    end
  
    def check_receiver_email      
      unless self.receiver
        self.receiver = ( User.find(self.receiver_id) if self.receiver_id ) rescue nil
        self.receiver = ( User.find_by_email(self.receiver_email) if self.receiver_email && self.receiver.nil? ) rescue nil
      end 
      self.receiver_email = self.receiver.email if self.receiver && (self.receiver_email || "").blank?
      self.receiver_honey_amount = default_receiver_honey unless self.receiver_honey_amount
      self.sender_honey_amount = default_reward_honey unless self.sender_honey_amount
    end
    
    def user_with_right_email?
      if (receiver_email || "").empty?
        errors.add(:receiver_email, "or Receiver User could not be blank") 
        return false
      end
      if receiver && receiver.email != receiver_email 
        errors.add(:receiver_email, "is not #{receiver.full_name}'s email: #{receiver.email}")
        return false
      end
      if sender && sender.email == receiver_email 
        errors.add(:receiver_email, "is the same to sender (#{receiver.full_name}'s email: #{receiver.email})")
        return false
      end
      return true
    end
    
    def generate_token_key
      self.status = STATUES[:pending] unless self.status
      unless self.token_key
        begin
          token = Digest::MD5.hexdigest "#{SecureRandom.hex(20)}-#{DateTime.now.to_s}"
        end while FreeHoney.where(:token_key => token).exists?
        self.token_key = token
      end
      self.expired_date = (DateTime.now + default_expired_days.days) unless self.expired_date
    end
end
