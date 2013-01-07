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
  
  has_many :shipping_stamps, :order => "created_at desc"
  
  has_many :notifications, :as => :notify_object, :class_name => "Notification"
  after_create :create_notification
  
  
  TYPES = {:trade_ins => 0, :order => 1}
  STATUES = {:pending => 0, :completed => 1, :declined => 2, :cancelled => 3, :confirmed_to_ship => 4}
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
    return "Cancelled" if self.status && self.status == STATUES[:cancelled] 
    return "Confirmed, wait to ship" if self.status && self.status == STATUES[:confirmed_to_ship] 
    return "Pending, waiting for arrival"
  end
  
  def shipping_method_name
    return "" if self.shipping_method.nil || self.shipping_method.blank?
    SHIPPING_METHOD_NAMES[self.shipping_method.to_sym]
  end
  
  def shipping_address_valid?
    return true if Rails.env != 'production'
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
    if Rails.env == 'production'
      stamp = is_order? ? create_shipping_order : create_shipping_label
    else
      stamp = create_test_stamp
    end
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
    [shipping_first_name, shipping_last_name].join(" ")
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
       field :honey_price
       field :user
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
       field :shipping_stamps
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
  
  def create_notification
    notification = self.notifications.new(:user_id => self.user.id)
    if self.is_trade_ins?
      notification.title = "#{product.title} - Processing"
      notification.description = "Trade-ins ##{self.id} created for #{self.product.title}, #{self.honey_price} Honey" 
    else
      notification.title = "#{product.title} Processing"
      notification.description = "Order ##{self.id} created for #{self.product.title}, #{self.honey_price} Honey" 
    end 
    notification.save
  end
    
  def create_notification_to_decline
    return unless self.is_trade_ins?
    
    notification = self.notifications.new(:user_id => self.user.id)
    notification.title = "#{product.title} - Declined"
    notification.description = "Trade-ins ##{self.id}: #{self.product.title} - #{self.honey_price} Honey - Declined" 
    notification.save
    
    OrderNotifier.product_declined(self).deliver
  end
    
  def create_notification_to_cancel
    notification = self.notifications.new(:user_id => self.user.id)
    if self.is_trade_ins? 
      notification.title = "#{product.title} - Cancelled"
      notification.description = "Trade-Ins ##{self.id}: #{self.product.title} - #{self.honey_price} Honey - Cancelled" 
    else
      notification.title = "#{product.title} - Cancelled"
      notification.description = "Order ##{self.id}: #{self.product.title} - #{self.honey_price} Honey - Cancelled" 
    end
    notification.save
    
    OrderNotifier.order_cancel(self).deliver
  end
  
  
  def create_notification_to_complete
    notification = self.notifications.new(:user_id => self.user.id)
    if self.is_trade_ins? 
      notification.title = "Product verified"
      notification.description = "Trade-ins ##{self.id}: #{self.product.title} (#{self.honey_price} Honey) is verified successfully." 
    else
      notification.title = "Order ##{self.id} is completed"
      notification.description = "#{notify_type} ##{self.id} is completed with the product #{self.product.title} and #{self.honey_price} Honey" 
    end 
    notification.save
    
    OrderNotifier.trade_ins_compelte(self).deliver if self.is_trade_ins?
  end
  
  private
  
    def adjust_current_balance
      if self.is_trade_ins?
        self.user.update_attribute :honey_balance, ((self.user.honey_balance || 0) + self.honey_price)
      else
        self.user.update_attribute :honey_balance, ((self.user.honey_balance || 0) - self.honey_price)
      end
    end
    
    def create_test_stamp
      { :integrator_tx_id => self.id,
        :tracking_number => "9405511201080126838437",
        :rate => {:service_type => "US-PM",
                  :amount => 6.2,
                  :package_type => "Package",
                  :ship_date => "2013-01-06"},
        :stamps_tx_id => "382c3dfb-5248-4755-9313-63cedfb6aed6",
        :url => "#{File.expand_path(Rails.root)}/public/images/label-200.png"
      }
    end
end
