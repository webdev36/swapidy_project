class Category < ActiveRecord::Base
  attr_accessible :title
  
  belongs_to :user
  has_many :products
  
end
