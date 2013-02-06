class Notification < ActiveRecord::Base

  attr_accessible :has_read, :notify_object_id, :notify_object_type, :title, :user_id, :description
  
  belongs_to :notify_object, :polymorphic => true
  belongs_to :user
  
  scope :unread, :conditions => {:has_read => false}
  scope :be_read, :conditions => {:has_read => true}
  
#  def self.purchase_honey_notify(payment)
#    notification = Notification.new(:title => "#{number_format(payment.honey_money)} Honey Purchased")
#    notification.notify_object = payment
#    notification.user = payment.user
#    notification.description = "#{number_format(payment.honey_money)} Honey Purchased with $#{payment.amount} at #{payment.created_at.strftime("%H:%M %b %d, %Y")}"
#    notification.save
#    UserNotifier.honey_purchase(payment).deliver
#  end
  
  def self.number_format(numer_value)
    result = ""
    numer_value.to_s.split(//).reverse.each_with_index do |char_value, index|
      result = "#{char_value}#{"," if index%3 == 0 && index > 0}#{result}"
    end
    return result
  end
end
