class Product < ActiveRecord::Base
  attr_accessible :title
  
  belongs_to :user
  belongs_to :category
  
  has_many :product_models

  
end
