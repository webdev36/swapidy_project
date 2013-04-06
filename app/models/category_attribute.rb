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
    total_count_for_buy = 0
    total_count_for_sell = 0
    total_count_for_sell_only = 0

    product_model_attributes.each do |model_attr|
      class_types << "attr_filter_model_#{model_attr.product_model.id}_for_buying" if model_attr.count_for_buy > 0
      class_types << "attr_filter_model_#{model_attr.product_model.id}_for_selling" if model_attr.count_for_sell > 0
      class_types << "attr_filter_model_#{model_attr.product_model.id}_for_sell_only" if model_attr.count_for_sell_only > 0

      total_count_for_buy += model_attr.count_for_buy
      total_count_for_sell += model_attr.count_for_sell
      total_count_for_sell_only += model_attr.count_for_sell_only
    end 
    
    class_types << "attr_filter_model_all_for_buying" if total_count_for_buy > 0
    class_types << "attr_filter_model_all_for_selling" if total_count_for_sell > 0
    class_types << "attr_filter_model_all_for_sell_only" if total_count_for_sell_only > 0
    class_types.uniq.join(" ")
  end
  
  def attributes_in_models
    attribute_values = {}
    attribute_titles = {}
    for_buy_attributes = {}
    for_sell_attributes = {}
    for_sell_only_attributes = {}

    self.product_model_attributes.each do |attribute|
      attribute_titles.merge! attribute.gen_filter_id => attribute.value
      
      if attribute_values[attribute.gen_filter_id]
        attribute_values[attribute.gen_filter_id] << attribute
        for_buy_attributes[attribute.gen_filter_id] += attribute.count_for_buy
        for_sell_attributes[attribute.gen_filter_id] += attribute.count_for_sell
        for_sell_only_attributes[attribute.gen_filter_id] += attribute.count_for_sell_only
      else
        for_buy_attributes.merge! attribute.gen_filter_id => attribute.count_for_buy
        for_sell_attributes.merge! attribute.gen_filter_id => attribute.count_for_sell
        for_sell_only_attributes.merge! attribute.gen_filter_id => attribute.count_for_sell_only
        attribute_values.merge! attribute.gen_filter_id => [attribute]
      end
    end
    return attribute_values.keys.reject{|key| (for_buy_attributes[key] 
      + for_sell_attributes[key] 
      + for_sell_only_attributes[key]) == 0 }
    .map{|key| [key, 
      attribute_titles[key], 
      attribute_values[key], 
      for_buy_attributes[key], 
      for_sell_attributes[key],
      for_sell_only_attributes[key]] }
  end
  def get_attributes_models
    result = []
    attribute_filters = []
    filter_key = ""
    filter_count = 0
    self.product_model_attributes.group(:value).each do |attribute|
      if attribute.value.present?        
        attr_val = attribute.value.strip
        filter_key = "filter_#{self.id}_#{attr_val.downcase}"
        filter_name = attr_val
        sell_products = self.category.products.all(:conditions=>["swap_type=? and product_model_attributes.value=?", "1", "#{attr_val}"], 
        :joins=>"left join product_model_attributes on products.product_model_id=product_model_attributes.product_model_id", 
        :group=>"products.product_model_id")        
        attribute_filters << "attr_filter_model_all_for_selling" if sell_products.count > 0
        filter_count += sell_products.count
        sell_products.each do |sp|
          attribute_filters << "attr_filter_model_#{sp.product_model.id}_for_selling"
        end

        buy_products = self.category.products.all(:conditions=>["swap_type=? and product_model_attributes.value=?", "2", "#{attr_val}"], 
          :joins=>"left join product_model_attributes on products.product_model_id=product_model_attributes.product_model_id", 
          :group=>"products.product_model_id")
        attribute_filters << "attr_filter_model_all_for_buying" if buy_products.count > 0
        filter_count += buy_products.count
        buy_products.each do |bp|
          attribute_filters << "attr_filter_model_#{bp.product_model.id}_for_buying"
        end

        sell_only_products = self.category.products.all(:conditions=>["swap_type=? and product_model_attributes.value=?", "3", "#{attr_val}"], 
          :joins=>"left join product_model_attributes on products.product_model_id=product_model_attributes.product_model_id", 
          :group=>"products.product_model_id")
        attribute_filters << "attr_filter_model_all_for_sell_only" if sell_only_products.count > 0
        filter_count += sell_only_products.count
        sell_only_products.each do |sop|
          attribute_filters << "attr_filter_model_#{sop.product_model.id}_for_sell_only"
        end                
        result << [filter_key, filter_name, attribute_filters.uniq] if filter_count > 0
      end      
    end    
    return result
  end

  after_save :expired_fragment_caches
  after_destroy :expired_fragment_caches
  
  private
    
    def expired_fragment_caches
      ActionController::Base.new.expire_fragment("homepage_container_category_#{category.id}") rescue nil
      ActionController::Base.new.expire_fragment("homepage_category_#{category.id}_filter_attr") rescue nil
    end
  
end
