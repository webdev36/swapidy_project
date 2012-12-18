class ProductPrice < ActiveRecord::Base
  attr_accessible :honey_price, :quality_status
  
  belongs_to :product_model
  
  QUALITY_STATUSES = {:poor => "Poor", :good => "Good", :flawless => "Flawless"}
  

end
