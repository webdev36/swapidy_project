class ProductModel < ActiveRecord::Base
  attr_accessible :title, :comment
  
  belongs_to :category
  has_many :products

  has_many :product_model_attributes
  #has_many :category_attributes, :thought => :product_model_attributes
  
  has_attached_file :image, :styles => {:thumb => "50x50>", :medium => "200x200>"}, :default_url => '/images/default_:style.png'
   
end
