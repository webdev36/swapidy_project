class ProductModelAttribute < ActiveRecord::Base
  
  attr_accessible :value, :product_model_id, :category_attribute_id
  
  belongs_to :product_model
  belongs_to :category_attribute
  has_many :product_attributes
  has_many :products, :through => :product_attributes
  
  def to_s
    title
  end
  
  def title
    [product_model.title, category_attribute.title, value].join(" - ") rescue ""
  end
  
  def attribute_value
    return CategoryAttribute.convert_value(self.category_attribute.attribute_type, self.value)
  end
  
  def gen_fitler_id
    "prod_model_attr_#{self.id}"
  end
  
  after_save :expired_fragment_caches
  after_destroy :expired_fragment_caches
  
  def expired_fragment_caches
    ActionController::Base.new.expire_fragment("homepage_category_#{product_model.category.id}_filter_attr")
    ActionController::Base.new.expire_fragment("homepage_container_category_#{category_attribute.category.id}")
  end

end
