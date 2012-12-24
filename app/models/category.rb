class Category < ActiveRecord::Base
  attr_accessible :title, :image_file_name, :image_content_type, :image_file_size
  
  belongs_to :user
  has_many :products
  has_many :product_models
  has_many :category_attributes
  
  has_attached_file :image, :styles => {:thumb => "100x100>", :medium => "150x150>", :large => "200x200>"}, :default_url => '/images/default_cat_:style.png'
  
  def image_url(type)
    if self.image_file_name.index("/images/") == 0
      return self.image_file_name #For testing only
    else
      self.image.url(type)
    end
  end
end
