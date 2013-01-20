class Category < ActiveRecord::Base
  attr_accessible :title, :image_file_name, :image_content_type, :image_file_size
  
  belongs_to :user
  has_many :products
  has_many :product_models
  has_many :category_attributes
  has_many :images, :as => :for_object, :class_name => "Image"

  def main_image_url(type)
    main_image.photo.url(type)
  end
  
  def main_image
    images.where(:is_main => true).first || self.images.first || images.new
  end

  after_save :expired_fragment_caches
  after_destroy :expired_fragment_caches_for_destroy

  def price_range_model_filters(price_range_key = nil)
    html = ""
    if price_range_key.nil?
      html = "attr_filter_model_all_for_buying attr_filter_model_all_for_selling "
      html += product_models.map{|model| "attr_filter_model_#{model.id}_for_buying attr_filter_model_#{model.id}_for_selling"}.join(" ")
    elsif Product::PRICE_RANGES.keys.include?(price_range_key)
      html += "attr_filter_model_all_for_selling " if products.for_sell.price_range(price_range_key).count > 0
      html += "attr_filter_model_all_for_buying " if products.for_buy.price_range(price_range_key).count > 0
      html += product_models.map{|model| model.price_range_filter_content(price_range_key) }.join(" ")
    end
    html
  end
  
  def expired_fragment_caches
    ActionController::Base.new.expire_fragment("homepage_container_category_#{self.id}_filter_attr") rescue nil
    ActionController::Base.new.expire_fragment("homepage_available_categories")
  end  
  
  private
    
    def expired_fragment_caches_for_destroy
      expired_fragment_caches
      ActionController::Base.new.expire_fragment("homepage_container_category_#{self.id}")
    end
end
