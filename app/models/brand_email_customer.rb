class BrandEmailCustomer < ActiveRecord::Base

  attr_accessible :brand_email_id, :user_id, :email, :status
  
  belongs_to :user
  belongs_to :brand_email
  
  validates :email, :status, :presence => true
  validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Invalid email address"}
  
  STATUS = {:sending => 0, :sent => 1, :failure => 2}
  scope :sending, :conditions => {:status => 0}
  scope :sent, :conditions => {:status => 1}
  scope :failure, :conditions => {:status => 2}

  def send_email
    #if self.user
    #  notification = self.user.notifications.new(:user_id => self.user.id)
    #  notification.title = "Support Customer's email sent"
    #  notification.description = "Please check your email about: #{self.brand_email.title}"
    #  notification.save
    #end
    UserNotifier.brand_email(self.email, self.brand_email.title, self.brand_email.content).deliver
    self.update_attribute(:status, STATUS[:sent])
  end
end
