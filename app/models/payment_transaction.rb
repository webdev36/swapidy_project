

class PaymentTransaction < ActiveRecord::Base
  
  attr_accessible :card_type, :card_name, :card_expired_month, :card_expired_year, :card_last_four_number
  include CardInfo

  attr_accessible :payment_invoice_id, :amount, :honey_money, :gateway, :payment_charge_id, :type, :status

  belongs_to :user
  
  GATEWAY = {:stripe => 0}
  TYPES = {:charge => "charge", :refund => "refund"}

end
