class CategoryAttribute < ActiveRecord::Base

  attr_accessible :title, :attribute_type, :category_id
  belongs_to :category

  has_many :product_model_attributes
  
  scope :general, :where => "category_id is NULL"

  ATTRIBUTE_TYPES = {:string => "String", :boolean => "Yes/No", :decimal => "Number"}
  
  def self.convert_value(type, value)
    return nil unless ATTRIBUTE_TYPES.values.include?(type)
    if type == ATTRIBUTE_TYPES[:string]
      return value
    elsif type == ATTRIBUTE_TYPES[:boolean]
      return Boolean.new(value) rescue false
    elsif type == ATTRIBUTE_TYPES[:number]
      return Decimal.new(value) rescue nil
    end
  end
  
  def to_s
    [category.title, title].join(" - ")
  end
  
  def attributes_in_models
    attribute_values = {}
    self.product_model_attributes.each do |attribute|
      if attribute_values.keys.include? attribute.value
        attribute_values[attribute.value] << attribute.product_model
      else
        attribute_values.merge! attribute.value => [attribute.product_model]
      end
    end
    return attribute_values.keys.map{|key| [key, attribute_values[key] ] }
  end

  after_save :expired_fragment_caches
  after_destroy :expired_fragment_caches
  
  private
    
    def expired_fragment_caches
      ActionController::Base.new.expire_fragment("homepage_container_category_#{category.id}")
      ActionController::Base.new.expire_fragment("homepage_category_#{category.id}_filter_attr")
    end
  
end
