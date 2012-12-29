require 'stamps_shipping_gateway'

class Order < ActiveRecord::Base
  include StampsShippingGateway
  
  attr_accessible :order_type, :status, :product_id, :honey_price, :using_condition, 
                  :shipping_first_name, :shipping_last_name, :shipping_address, :shipping_optional_address,
                  :shipping_city, :shipping_state, :shipping_zip_code, :shipping_country, :shipping_method,
                  :candidate_addresses, :shipping_zip_code_add_on
  
  validates :order_type, :status, :presence => true
  validates :shipping_first_name, :shipping_last_name, :shipping_address, :shipping_city, :shipping_state, 
            :shipping_zip_code, :shipping_country, :presence => true

  attr_accessor :candidate_addresses, :shipping_zip_code_add_on

  belongs_to :product
  belongs_to :user
  
  has_many :shipping_stamps
  
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
    return "" if self.shipping_method.nil || self.shipping_method.blank?
    SHIPPING_METHOD_NAMES[self.shipping_method.to_sym]
  end
  
  def shipping_address_valid?
    result = verify_shipping_address
    errors.add(:shipping_address, "could not be found") unless result
    return result
  end
  
  def create_new_stamp
    stamp = is_order? ? create_shipping_order : create_shipping_label
    new_stamp = shipping_stamps.new
    new_stamp.integrator_tx_id = stamp[:integrator_tx_id]
    new_stamp.tracking_number = stamp[:tracking_number]
    new_stamp.service_type = stamp[:rate][:service_type]
    new_stamp.rate_amount = stamp[:rate][:amount]
    new_stamp.package_type = stamp[:rate][:package_type] 
    new_stamp.due_date = stamp[:rate][:ship_date]
    new_stamp.stamps_tx_id = stamp[:stamps_tx_id]
    new_stamp.url = stamp[:url]
    new_stamp.status = "pending"
    return new_stamp if new_stamp.save
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
