class FreeHoney < ActiveRecord::Base
  attr_accessible :completed_at, :receiver_email, :expired_date, :sender_amount, :receiver_amount, :status, :token_key, :receiver_id, :sender_id
  
  belongs_to :receiver, :foreign_key => "receiver_id", :class_name => "User"
  belongs_to :sender, :foreign_key => "sender_id", :class_name => "User"
   
  STATUES = {:pending => 0, :completed => 1, :declined => 2, :cancelled => 3}
  validates :receiver_amount, :status, :expired_date, :token_key, :presence => true
  validates :receiver_email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Invalid email address"}
  validate :user_with_right_email?
  validates_uniqueness_of :receiver_email, :message => "Sorry, this email has been submitted before."
  
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
      self.receiver = User.signup_user({:email => self.receiver_email}, :free_money_signup)
    end
    self.status = STATUES[:completed] 
    self.sender_amount = default_reward_money
    self.completed_at = Time.now
    self.save

    self.receiver.update_attribute(:balance_amount, (self.receiver.balance_amount || 0.00) + self.receiver_amount)
    receiver_notification = Notification.new(:title => "#{self.receiver_amount} FREE Money Promo")
    receiver_notification.user = self.receiver
    receiver_notification.description = "#{self.receiver_amount} FREE Money Redeemed"
    receiver_notification.save
    UserNotifier.free_money_completed(self).deliver

    #create_reward_and_bonus
    if self.sender
      self.sender.update_attribute(:balance_amount, (self.sender.balance_amount || 0.00) + self.sender_amount)
      sender_notification = Notification.new(:title => "Free Money Reward")
      sender_notification.user = self.sender
      sender_notification.description = "Free #{self.sender_amount} Money Reward: #{receiver_title} accepted your invitation}"
      sender_notification.save
      UserNotifier.free_money_reward(self).deliver 
    end
    
    other_free_money = FreeHoney.pending.where(:receiver_email => self.receiver_email).where("id != #{self.id}").each do |other_one|
      other_one.update_attribute(:status => STATUES[:cancelled])
    end
    return true
  end
  
  def receiver_title(mode = :full_name)
    if mode.to_s == "full_name"
      return receiver && !receiver.blank_name? ? "#{receiver.full_name} <#{receiver.email}>" : receiver_email  
    else
      return receiver_email  
    end
  end
  
  def sender_title(mode = :full_name)
    if mode.to_s == "full_name"
      return sender && !sender.blank_name? ? "#{sender.full_name} <#{sender.email}>" : "Swapidy"
    else
      return sender ? sender.email : "Swapidy"
    end
  end
    
  def create_notifications
    if sender
      sender_notification = Notification.new(:title => "Free Money Sent")
      sender_notification.user = self.sender
      sender_notification.description = "Free Money: sent to #{receiver_title} at #{self.created_at.strftime("%b %d, %Y")}"
      sender_notification.save
    end
    
    if receiver
      receiver_notification = Notification.new(:title => "Free #{self.receiver_amount} Money Invitation")
      receiver_notification.user = self.receiver
      receiver_notification.description = "Free #{self.receiver_amount} Money: sent from #{sender_title}"
      receiver_notification.save
    end
    UserNotifier.free_money_sent(self).deliver
  end

  private
  
    def default_expired_days
      (SwapidySetting.get('FREE_MONEY-DEFAULT_EXPIRED_DAYS') || "7").to_i rescue 7
    end
    
    def default_reward_money  
      (SwapidySetting.get('FREE_MONEY-DEFAULT_REWARD_MONEY') || "10").to_f rescue 10.0
    end
    
    def default_receiver_money
      (SwapidySetting.get('FREE_MONEY-DEFAULT_RECEIVER_MONEY') || "5").to_f rescue 5.0
    end
  
    def check_receiver_email      
      unless self.receiver
        self.receiver = ( User.find(self.receiver_id) if self.receiver_id ) rescue nil
        self.receiver = ( User.find_by_email(self.receiver_email) if self.receiver_email && self.receiver.nil? ) rescue nil
      end 
      self.receiver_email = self.receiver.email if self.receiver && (self.receiver_email || "").blank?
      self.receiver_amount = default_receiver_money unless self.receiver_amount
      self.sender_amount = default_reward_money unless self.sender_amount
    end
    
    def user_with_right_email?
      if (receiver_email || "").empty?
        errors.add(:receiver_email, "or Invite email can't be blank.") 
        return false
      end
      if receiver && receiver.email != receiver_email 
        errors.add(:receiver_email, "Invalid Sender #{receiver.full_name}'s email: #{receiver.email}.")
        return false
      end
      if sender && sender.email == receiver_email 
        errors.add(:receiver_email, "Sorry, you can't send invites to yourself. #{receiver.email}.")
        return false
      end
      if receiver_email && User.where(:email => self.receiver_email).exists?
        errors.add(:receiver_email, "That email address has signed up already.") 
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
