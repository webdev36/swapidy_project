class Order < ActiveRecord::Base
  attr_accessible :order_type, :status
  
  belongs_to :product
  belongs_to :user
  
  TYPES = {:trade_ins => 0, :order => 1}
  STATUES = {:pending => 0, :fulfilled => 1, :declined => 2}

  scope :trade_ins, :where => {:order_type => 0}
  scope :order_type, :where => {:order_type => 1}
  
  def title
    return self.product.title unless self.product.title.blank?
    return "#{self.product.category.title} #{self.product.product_model.title}"
  end
  
  def status_title
    return "Fulfilled" if self.status && self.status == STATUES[:fulfilled]
    return "Declined" if self.status && self.status == STATUES[:declined] 
    return "Pending"
  end
end
