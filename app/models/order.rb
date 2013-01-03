require 'stamps_shipping_gateway'

class Order < ActiveRecord::Base
  include StampsShippingGateway
  
  attr_accessible :order_type, :status, :product_id, :honey_price, :using_condition, 
                  :shipping_first_name, :shipping_last_name, :shipping_address, :shipping_optional_address,
                  :shipping_city, :shipping_state, :shipping_zip_code, :shipping_country, :shipping_method,
                  :candidate_addresses, :shipping_zip_code_add_on, :is_candidate_address
  
  validates :order_type, :status, :presence => true
  validates :shipping_first_name, :shipping_last_name, :shipping_address, :shipping_city, :shipping_state, 
            :shipping_zip_code, :shipping_country, :presence => true

  attr_accessor :candidate_addresses, :is_candidate_address

  belongs_to :product
  belongs_to :user
  
  has_many :shipping_stamps
  
  TYPES = {:trade_ins => 0, :order => 1}
  STATUES = {:pending => 0, :completed => 1, :declined => 2}
  SHIPPING_METHODS = {:box => "box", :usps => "usps", :fedex => "fedex"}
  
  SHIPPING_METHOD_NAMES = { :box => "A box and prepaid label", 
                            :usps => "Prepaid USPS Shipping Label", 
                            :fedex => "Prepaid FedEx Shipping Label"}
  
  after_create :adjust_current_balance

  scope :to_sell, :conditions => {:order_type => TYPES[:trade_ins]}
  scope :to_buy, :conditions => {:order_type => TYPES[:order]}
  scope :not_completed, :conditions => ["status != ?", STATUES[:completed]]
  
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
    return "Completed" if self.status && self.status == STATUES[:completed]
    return "Declined" if self.status && self.status == STATUES[:declined] 
    return "Pending, waiting for arrival"
  end
  
  def shipping_method_name
    return "" if self.shipping_method.nil || self.shipping_method.blank?
    SHIPPING_METHOD_NAMES[self.shipping_method.to_sym]
  end
  
  def shipping_address_valid?
    result = verify_shipping_address
    #return true if is_candidate_address && !result && candidate_addresses && !candidate_addresses.empty? 
    if !result && candidate_addresses && !candidate_addresses.empty? 
      errors.add(:shipping_address, "is confused with nearly same addresses. Need confirm again to make sure!") 
    elsif !result
      errors.add(:shipping_address, "could not be found") 
    end
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
  
  def shipping_fullname
  
  end
  
  def shipping_full_address
    html = shipping_address 
    html += "(Optional: #{shipping_optional_address})" if shipping_optional_address && !shipping_optional_address.blank?
    html += "#{shipping_city}, #{shipping_state}, #{shipping_zip_code}"
    return html
  end
  
  rails_admin do
    configure :order_type do
      read_only true
      pretty_value do
        util = bindings[:object]
        util.order_type == TYPES[:order] ? "Order" : "Trade-Ins"
      end
    end
    
    configure :status, :enum do
      pretty_value do
        util = bindings[:object]
        util.status_title
      end
      enum do
        [['Pending, waiting for arrival', STATUES[:pending]], ['Completed', STATUES[:completed]], ['Declined', STATUES[:declined]]]
      end
    end
    configure :using_condition, :enum do
      enum do
        Product::USING_CONDITIONS.keys.map {|key| [Product::USING_CONDITIONS[key], Product::USING_CONDITIONS[key]]}
      end
    end
    
    list do
       field :order_type
       field :status
       field :product
       
       field :user
       field :shipping_fullname
     end
     export do
       field :order_type
       field :status
       field :product
       field :weight_lb
       field :using_condition
       field :honey_price
       
       field :user
       field :shipping_fullname
       field :shipping_address
       field :shipping_city
       field :shipping_state
       field :shipping_zip_code
     end
     show do
       field :order_type
       field :status
       field :product
       field :weight_lb
       field :using_condition
       field :honey_price
       
       field :user
       field :shipping_fullname
       field :shipping_full_address
     end
     edit do
       field :order_type
       field :status
       field :product
       field :weight_lb
       field :using_condition
       field :honey_price
       
       field :user
       field :shipping_first_name
       field :shipping_last_name
       field :shipping_address
       field :shipping_city
       field :shipping_state, :enum do
         enum do 
           Carmen::Country.named('United States').subregions.collect { |sr| [sr.name, sr.code] }
         end
       end
       field :shipping_zip_code
     end
  #   create do; end
  #   update do; end
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
