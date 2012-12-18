class ProductModel < ActiveRecord::Base
  attr_accessible :title, :memory_space, :comment
  
  belongs_to :product
  has_many :product_prices
  
  has_attached_file :image, :styles => {:thumb => "50x50>", :medium => "200x200>"}, :default_url => '/images/default_:style.png'
   
end
