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
  
  has_many :images, :as => :for_object

  def main_image_url(type)
    main_image.photo.url(type)
  end
  
  def main_image
    return (images.where(:is_main => true).first || images.first) if images.count > 0
    return category.main_image if product_model.images.count == 0
    return product_model.main_image if self.product_model_attributes.count == 0

    cat_color_attr = self.category.category_attributes.find_by_title "Color"
    color_attr_value = product_model_attributes.where(:category_attribute_id => cat_color_attr.id).first if cat_color_attr

    #return image based on color if it existed
    result_image = product_model.images.find(:first, :conditions => ["sum_attribute_names like ?", "%#{color_attr_value.value}%"]) if color_attr_value
    return result_image if result_image

    #return images with nearly same attributes 
    cond_params = product_model_attributes.map{|a| a.value}
    sql = cond_params.map{|attr_value| "(sum_attribute_names like ? )"}.join(" AND ")
    like_image = product_model.images.find(:first, :conditions => ( [sql] + cond_params.map{|p| "%#{p}%" })) unless cond_params.empty?

    return like_image || product_model.main_image
  end

  def gen_attribute_names
    result = []
    self.product_model_attributes.each do |product_model_attribute|
      result << product_model_attribute.value
    end
    result.join(" ")
  end
  
end
