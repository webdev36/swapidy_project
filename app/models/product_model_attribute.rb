class ProductModelAttribute < ActiveRecord::Base
  
  attr_accessible :value
  
  belongs_to :product_model
  belongs_to :category_attribute
  has_many :product_attributes
  has_many :products, :through => :product_attributes
  
  def attribute_value
    return CategoryAttribute.convert_value(self.category_attribute.attribute_type, self.value)
  end
  
  after_save :expired_fragment_caches
  after_destroy :expired_fragment_caches
  
  def expired_fragment_caches
    ActionController::Base.new.expire_fragment("homepage_category_#{product_model.category.id}_filter_attr")
    ActionController::Base.new.expire_fragment("homepage_container_category_#{category.id}")
  end

end
