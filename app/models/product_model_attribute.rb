class ProductModelAttribute < ActiveRecord::Base
  
  attr_accessible :value, :product_model_id, :category_attribute_id
  
  belongs_to :product_model
  belongs_to :category_attribute
  has_many :product_attributes
  has_many :products, :through => :product_attributes
  
  def to_s
    title
  end
  
  def count_for_buy
    self.products.for_buy.count
  end

  def count_for_sell
    self.products.for_sell.count
  end
  
  def count_for_sell_only
    self.products.for_sell_only.count
  end

  def filter_content
    result = ""
    result += " attr_filter_model_#{self.product_model.id}_for_selling" if self.products.for_sell.count > 0
    result += " attr_filter_model_#{self.product_model.id}_for_buying" if self.products.for_buy.count > 0
    result += " attr_filter_model_#{self.product_model.id}_for_sell_only" if self.products.for_sell.count > 0
    return result
  end

  def title
    [product_model.title, category_attribute.title, value].join(" - ") rescue ""
  end
  
  def attribute_value
    return CategoryAttribute.convert_value(self.category_attribute.attribute_type, self.value)
  end
  
  def gen_filter_id
    ext_name = [category_attribute.id.to_s, value].join("_").parameterize
    return "filter_#{ext_name}"
  end
  
  after_save :expired_fragment_caches
  after_destroy :expired_fragment_caches
  
  def expired_fragment_caches
    ActionController::Base.new.expire_fragment("homepage_category_#{product_model.category.id}_filter_attr") rescue nil
    ActionController::Base.new.expire_fragment("homepage_container_category_#{category_attribute.category.id}") rescue nil
  end

end
