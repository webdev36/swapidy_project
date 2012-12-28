class ShippingStamp < ActiveRecord::Base
  
  attr_accessible :integrator_tx_id, :tracking_number, :service_type, :rate_amount, :package_type, 
                  :due_date, :stamps_tx_id, :url, :status
  
  belongs_to :order
  
end
