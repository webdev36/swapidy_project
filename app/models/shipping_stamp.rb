class ShippingStamp < ActiveRecord::Base
  
  attr_accessible :integrator_tx_id, :tracking_number, :service_type, :rate_amount, :package_type, 
                  :due_date, :stamps_tx_id, :url, :status
  
  belongs_to :order
  
  #after_create :send_email_to_customer
  
  
  def send_email_to_customer
    if self.order.is_trade_ins?
      OrderNotifier.confirm_to_sell(self.order, self).deliver
    else
      OrderNotifier.confirm_to_buy(self.order, self).deliver
    end
  end
  
  
end
