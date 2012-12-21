class Order < ActiveRecord::Base
  
  attr_accessible :order_type, :status, :product_id, :honey_price, :using_condition,
                  :email, :email_confirmation, :stripe_email, :stripe_email_confirmation, :stripe_customer_id,
                  :shipping_first_name, :shipping_last_name, :shipping_address, :shipping_optional_address,
                  :shipping_city, :shipping_state, :shipping_zip_code, :shipping_country, :shipping_method

  attr_accessor :email_confirmation, :stripe_email_confirmation
  
  #validates :order_type, :status, :honey_price, :presence => true
  #validates :shipping_first_name, :shipping_last_name, :shipping_address, :presence => true
  
  #validates :email, :presence => true, :format => { :with => EMAIL_REGEX, :allow_blank => true }  
  #validates :stripe_email, :presence => true, :format => { :with => EMAIL_REGEX, :allow_blank => true }  

  belongs_to :product
  belongs_to :user
  
  TYPES = {:trade_ins => 0, :order => 1}
  STATUES = {:pending => 0, :fulfilled => 1, :declined => 2}
  SHIPPING_METHODS = {:box => "box", :usps => "usps", :fedex => "fedex"}

  scope :to_sell, :conditions => {:order_type => TYPES[:trade_ins]}
  scope :to_buy, :conditions => {:order_type => TYPES[:order]}
  
  def title
    return self.product.title unless self.product.title.blank?
    return "#{self.product.category.title} #{self.product.product_model.title}"
  end
  
  def status_title
    return "Fulfilled" if self.status && self.status == STATUES[:fulfilled]
    return "Declined" if self.status && self.status == STATUES[:declined] 
    return "Pending"
  end
  
  def valid_to_buy?(step_name = :confirm)
    return true
  end
  
end
