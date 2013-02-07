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
  
  def applied_for_models_filter
    class_types = []
    total_count = 0
    product_model_attributes.each do |model_attr|
      class_types << "attr_filter_model_#{model_attr.product_model.id}" if model_attr.products.count > 0
      
      total_count += model_attr.products.count
    end 
    
    class_types << "attr_filter_model_all" if total_count > 0
    class_types.uniq.join(" ")
  end
  
  def attributes_in_models
    attribute_values = {}
    attribute_titles = {}
    attributes = {}
    self.product_model_attributes.each do |attribute|
      attribute_titles.merge! attribute.gen_fitler_id => attribute.value
      
      if attribute_values[attribute.gen_fitler_id]
        attribute_values[attribute.gen_fitler_id] << attribute
        attributes[attribute.gen_fitler_id] += attribute.products.count
      else
        attributes.merge! attribute.gen_fitler_id => attribute.products.count
        attribute_values.merge! attribute.gen_fitler_id => [attribute]
      end
    end
    return attribute_values.keys.reject{|key| attributes[key] == 0 }.map{|key| [key, attribute_titles[key], attribute_values[key], attributes[key]] }
  end

  after_save :expired_fragment_caches
  after_destroy :expired_fragment_caches
  
  private
    
    def expired_fragment_caches
      ActionController::Base.new.expire_fragment("homepage_container_category_#{category.id}") rescue nil
      ActionController::Base.new.expire_fragment("homepage_category_#{category.id}_filter_attr") rescue nil
    end
  
end
