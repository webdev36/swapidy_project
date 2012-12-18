class ProductModel < ActiveRecord::Base
  attr_accessible :title, :memory_space, :comment
  
  belongs_to :product
  has_many :product_prices
   
end
