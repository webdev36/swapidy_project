class Notification < ActiveRecord::Base
  attr_accessible :has_read, :notify_object_id, :notify_object_type, :title, :user_id, :description
  
  belongs_to :notify_object, :polymorphic => true
  
  scope :unread, :conditions => {:has_read => false}
  scope :be_read, :conditions => {:has_read => true}
  
end
