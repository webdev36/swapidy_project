class Product < ActiveRecord::Base

  attr_accessible :title, :honey_price, :product_model_id, :image_ids, :for_sell, :for_buy,
                  :product_attribute_ids, :product_model_attribute_ids, :price_for_good_type, :price_for_poor_type
  
  has_attached_file :image, :styles => {:thumb => "50x50>", :medium => "200x200>"}
  
  belongs_to :user
  belongs_to :category
  belongs_to :product_model

  has_many :product_attributes, :dependent => :destroy
  has_many :product_model_attributes, :through => :product_attributes
  
  USING_CONDITIONS = {:poor => "Poor", :good => "Good", :flawless => "Flawless"}
  
  has_many :images, :as => :for_object, :dependent => :destroy

  after_save :expired_fragment_caches
  after_destroy :expired_fragment_caches

  def main_image_url(type)
    main_image.photo.url(type)
  end
  
  def has_flawless_type?
    honey_price && honey_price > 0.0 rescue false
  end
  def has_poor_type?
    price_for_poor_type && price_for_poor_type > 0.0 rescue false
  end
  def has_good_type?
    price_for_good_type && price_for_good_type > 0.0 rescue false
  end
  
  def using_condition_types
    result = []
    result << "Flawless" if has_flawless_type?
    result << "Poor" if has_poor_type?
    result << "Good" if has_good_type?
    result.join(" ")
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

  def gen_attribute_filter_ids
    result = []
    self.product_model_attributes.each do |product_model_attribute|
      result << product_model_attribute.gen_fitler_id
    end
    result.join(" ")
  end
  
  def expired_fragment_caches
    ActionController::Base.new.expire_fragment("homepage_container_category_#{self.category.id}") rescue nil
    ActionController::Base.new.expire_fragment("homepage_product_container_category_#{self.category.id}") rescue nil
    ActionController::Base.new.expire_fragment("homepage_product_thumb_#{self.id}") rescue nil
  end
  
  def weight_lb
    product_model.weight_lb
  end
  
  rails_admin do
    
    list do
      field :title
      field :honey_price
      field :price_for_good_type
      field :price_for_poor_type
      field :for_sell
      field :for_buy
      field :category
      field :product_model
      field :images
    end
    export do
      field :title
      field :honey_price
      field :price_for_good_type
      field :price_for_poor_type
      field :for_sell
      field :for_buy
      field :category
      field :product_model
      field :images
      field :product_model_attributes
    end
    show do
      field :category
      field :product_model
      field :title
      field :honey_price
      field :price_for_good_type
      field :price_for_poor_type
      field :images
      field :product_attributes
    end
    edit do; end
    create do
      field :product_model
      field :title
      field :honey_price
      field :price_for_good_type
      field :price_for_poor_type
    end
    update do
      field :title
      field :honey_price
      field :price_for_good_type
      field :price_for_poor_type
      field :images
      field :product_attributes
    end
  end

end
