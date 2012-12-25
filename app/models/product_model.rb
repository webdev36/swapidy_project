class ProductModel < ActiveRecord::Base
  attr_accessible :title, :comment
  
  belongs_to :category
  has_many :products

  has_many :product_model_attributes
  #has_many :category_attributes, :thought => :product_model_attributes
  
  has_many :images, :as => :for_object

  def main_image_url(type)
    main_image.photo.url(type)
  end
  
  def main_image
    return (images.where(:is_main => true).first || images.first) if images.count > 0
    return category.main_image
  end

end
