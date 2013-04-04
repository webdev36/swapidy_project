class ProductModel < ActiveRecord::Base
  attr_accessible :title, :comment, :category_id, :weight_lb, :product_model_attribute_ids, :image_ids, :sort_number
  
  belongs_to :category
  has_many :products
  scope :sorted, :order => :sort_number 

  has_many :product_model_attributes
  #has_many :category_attributes, :thought => :product_model_attributes
  
  has_many :images, :as => :for_object

  def for_buy?
    self.products.for_buy.count > 0
  end

  def for_sell?
    self.products.for_sell.count > 0
  end
  def for_sell_only?
    self.products.for_sell_only.count > 0
  end
  def main_image_url(type)
    main_image.photo.url(type)
  end
  
  def price_range_filter_content(range)
    result = ""
    result += " attr_filter_model_#{self.id}_for_buying" if self.products.for_buy.price_range(range, :for_buy).count > 0
    result += " attr_filter_model_#{self.id}_for_selling" if self.products.for_sell.price_range(range, :for_sell).count > 0
    result += " attr_filter_model_#{self.id}_for_sell_only" if self.products.for_sell_only.price_range(range, :for_sell_only).count > 0
    return result
  end
  
  def main_image
    return (images.where(:is_main => true).first || images.first) if images.count > 0
    return category.main_image
  end
    
  after_save :expired_fragment_caches
  after_destroy :expired_fragment_cache_destroy
  
  def expired_fragment_caches
    ActionController::Base.new.expire_fragment("homepage_category_#{category.id}_filter_attr") rescue nil
    ActionController::Base.new.expire_fragment("homepage_container_category_#{category.id}") rescue nil
  end
  
  def expired_fragment_cache_destroy
    ActionController::Base.new.expire_fragment("homepage_category_#{category.id}_filter_attr") rescue nil
    ActionController::Base.new.expire_fragment("homepage_container_category_#{category.id}") rescue nil
    products.each { |product| product.expired_fragment_caches }
  end
    

end
