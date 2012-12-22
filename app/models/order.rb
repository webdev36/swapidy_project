class Order < ActiveRecord::Base
  
  attr_accessible :order_type, :status, :product_id, :honey_price, :using_condition,
                  :shipping_first_name, :shipping_last_name, :shipping_address, :shipping_optional_address,
                  :shipping_city, :shipping_state, :shipping_zip_code, :shipping_country, :shipping_method
  
  validates :order_type, :status, :presence => true
  validates :shipping_first_name, :shipping_last_name, :shipping_address, :shipping_city, :shipping_state, 
            :shipping_zip_code, :shipping_method, :shipping_country, :presence => true
  
  belongs_to :product
  belongs_to :user
  
  TYPES = {:trade_ins => 0, :order => 1}
  STATUES = {:pending => 0, :fulfilled => 1, :declined => 2}
  SHIPPING_METHODS = {:box => "box", :usps => "usps", :fedex => "fedex"}
  
  SHIPPING_METHOD_NAMES = { :box => "A box and prepaid label", 
                            :usps => "Prepaid USPS Shipping Label", 
                            :fedex => "Prepaid FedEx Shipping Label"}
  
  after_create :adjust_current_balance

  scope :to_sell, :conditions => {:order_type => TYPES[:trade_ins]}
  scope :to_buy, :conditions => {:order_type => TYPES[:order]}
  
  def is_trade_ins?
    order_type && order_type == TYPES[:trade_ins]
  end
  
  def is_order?
    order_type && order_type == TYPES[:order]
  end
  
  def title
    return self.product.title unless self.product.title.blank?
    return "#{self.product.category.title} #{self.product.product_model.title}"
  end
  
  def status_title
    return "Fulfilled" if self.status && self.status == STATUES[:fulfilled]
    return "Declined" if self.status && self.status == STATUES[:declined] 
    return "Pending"
  end
  
  def shipping_method_name
    SHIPPING_METHOD_NAMES[self.shipping_method.to_sym]
  end
  
  private
  
    def adjust_current_balance
      if self.is_trade_ins?
        self.user.update_attribute :honey_balance, ((self.user.honey_balance || 0) + self.honey_price)
      else
        self.user.update_attribute :honey_balance, ((self.user.honey_balance || 0) - self.honey_price)
      end
    end
end
