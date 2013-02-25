class BrandEmail < ActiveRecord::Base
  attr_accessible :content, :title, :customers, :sending_count, :sent_count, :failure_count, :suggest_user_emails

  has_many :brand_email_customers
  has_many :users, :through => :brand_email_customers
  validates :title, :presence => true, :length => { :maximum => 2000 }
  validates :content, :length => { :maximum => 2000 }, :presence => true
  validates :customers, :presence => true

  after_create :send_notifications
  
  def customers=(value)
    emails = []
    value.split(',').map{|email| email.strip}.each do |email|
      next if email.blank?
      next if emails.include?(email)
      emails << email
      user = User.find_by_email(email)
      customer = self.brand_email_customers.new(:email => email, :user_id => user ? user.id : nil)
      errors.add(:customers, "has invalid email \"#{email}\"") unless customer.valid? 
    end
  end
  
  def customers
    self.brand_email_customers.map {|c| c.email }.join(", ")
  end

  def email_total
    self.brand_email_customers.count
  end
  def sending_count
    self.brand_email_customers.sending.count
  end
  def sent_count
    self.brand_email_customers.sent.count
  end
  def failure_count
    self.brand_email_customers.failure.count
  end
  
  def suggest_user_emails
    User.all.map { |user| user.email }.join(", ")
  end
  
  private
  
    def send_notifications
      self.brand_email_customers.each {|item| item.send_email }
    end

end
