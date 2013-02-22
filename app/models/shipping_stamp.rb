class ShippingStamp < ActiveRecord::Base
  
  attr_accessible :integrator_tx_id, :tracking_number, :service_type, :rate_amount, :package_type, 
                  :due_date, :stamps_tx_id, :url, :status, :sell_or_buy
  
  scope :for_buy, :conditions => {:sell_or_buy => "buy"}
  scope :for_sell, :conditions => {:sell_or_buy => "sell"}
  ORDER_TYPES = {"sell" => "Sell", "buy" => "Buy"}
  
  belongs_to :order
  
end
