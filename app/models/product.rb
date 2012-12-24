class Product < ActiveRecord::Base

  attr_accessible :title, :using_condition, :honey_price
  
  has_attached_file :image, :styles => {:thumb => "50x50>", :medium => "200x200>"}
  
  belongs_to :user
  belongs_to :category
  belongs_to :product_model

  has_many :product_attributes
  has_many :product_model_attributes, :through => :product_attributes
  
  USING_CONDITIONS = {:poor => "Poor", :good => "Good", :flawless => "Flawless"}
  
  validates :honey_price, :using_condition, :presence => true
  
  def image_url(type = :medium)
    if self.image_file_name && self.image_file_name.index("/images/products/") == 0
      return self.image_file_name #For testing only
    elsif self.image_file_name && !self.image_file_name.blank?
      self.image.url(type)
    else
      self.category.image.url(type)
    end
  end
  
  def gen_attribute_names
    result = []
    self.product_model_attributes.each do |product_model_attribute|
      result << product_model_attribute.value
    end
    result.join(" ")
  end
  
end
