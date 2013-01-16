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
    attribute_titles = {}
    for_buy_attributes = {}
    for_sell_attributes = {}
    self.product_model_attributes.each do |attribute|
      attribute_titles.merge! attribute.gen_fitler_id => attribute.value
      
      if attribute_values[attribute.gen_fitler_id]
        attribute_values[attribute.gen_fitler_id] << attribute
        for_buy_attributes[attribute.gen_fitler_id] += attribute.count_for_buy
        for_sell_attributes[attribute.gen_fitler_id] += attribute.count_for_sell
      else
        for_buy_attributes.merge! attribute.gen_fitler_id => attribute.count_for_buy
        for_sell_attributes.merge! attribute.gen_fitler_id => attribute.count_for_sell
        attribute_values.merge! attribute.gen_fitler_id => [attribute]
      end
    end
    return attribute_values.keys.reject{|key| (for_buy_attributes[key] + for_sell_attributes[key]) == 0 }.map{|key| [key, attribute_titles[key], attribute_values[key], for_buy_attributes[key], for_sell_attributes[key]] }
  end

  after_save :expired_fragment_caches
  after_destroy :expired_fragment_caches
  
  private
    
    def expired_fragment_caches
      ActionController::Base.new.expire_fragment("homepage_container_category_#{category.id}") rescue nil
      ActionController::Base.new.expire_fragment("homepage_category_#{category.id}_filter_attr") rescue nil
    end
  
end
