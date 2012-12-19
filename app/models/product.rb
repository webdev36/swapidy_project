class Product < ActiveRecord::Base

  attr_accessible :title, :using_condition, :honey_price
  
  has_attached_file :image, :styles => {:thumb => "50x50>", :medium => "200x200>"}, :default_url => '/images/default_product_:style.png'
  
  belongs_to :user
  belongs_to :category
  belongs_to :product_model

  has_many :product_attributes
  
  USING_CONDITIONS = {:poor => "Poor", :good => "Good", :flawless => "Flawless"}
  
end
