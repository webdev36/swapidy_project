class ShippingStamp < ActiveRecord::Base
  
  attr_accessible :integrator_tx_id, :tracking_number, :service_type, :rate_amount, :package_type, 
                  :due_date, :stamps_tx_id, :url, :status, :sell_or_buy
  
  scope :for_buy, :conditions => {:sell_or_buy => "buy"}
  scope :for_sell, :conditions => {:sell_or_buy => "sell"}
  ORDER_TYPES = {"sell" => "Sell", "buy" => "Buy"}
  
  belongs_to :order
  
  #after_create :send_email_to_customer
  
  
  #def send_email_to_customer
  #  if self.order.is_trade_ins?
  #    OrderNotifier.confirm_to_sell(self.order, self).deliver
  #  else
  #    OrderNotifier.confirm_to_buy(self.order, self).deliver
  #  end
  #end
  
  def self.create_from_stamp_api order, order_stamp
      new_stamp = order.shipping_stamps.new
      new_stamp.integrator_tx_id = order_stamp[:integrator_tx_id]
      new_stamp.tracking_number = order_stamp[:tracking_number]
      new_stamp.service_type = order_stamp[:rate][:service_type]
      new_stamp.rate_amount = order_stamp[:rate][:amount]
      new_stamp.package_type = order_stamp[:rate][:package_type] 
      new_stamp.due_date = order_stamp[:rate][:ship_date]
      new_stamp.stamps_tx_id = order_stamp[:stamps_tx_id]
      new_stamp.url = order_stamp[:url]
      new_stamp.status = "pending"
      new_stamp.sell_or_buy = order_stamp[:sell_or_buy]
      new_stamp.save
      return new_stamp
  end
  
end
