class ProductPrice < ActiveRecord::Base
  attr_accessible :honey_price, :quality_status
  
  belongs_to :product_model

  has_attached_file :image, :styles => {:thumb => "50x50>", :medium => "200x200>"}, :default_url => '/images/default_:style.png'
  
  QUALITY_STATUSES = {:poor => "Poor", :good => "Good", :flawless => "Flawless"}
  

end
