class ProductModelAttribute < ActiveRecord::Base
  
  attr_accessible :value
  
  belongs_to :product_model
  belongs_to :category_attribute
  
  def attribute_value
    return CategoryAttribute.convert_value(self.category_attribute.attribyte_type, self.value)
  end

end
