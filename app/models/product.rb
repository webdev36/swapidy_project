class Product < ActiveRecord::Base

  attr_accessible :title, :honey_price, :product_model_id, :image_ids, :for_sell, :for_buy,
                  :product_attribute_ids, :product_model_attribute_ids, :price_for_good_type, :price_for_poor_type
  
  has_attached_file :image, :styles => {:thumb => "50x50>", :medium => "200x200>"}
  
  belongs_to :user
  belongs_to :category
  belongs_to :product_model

  
  has_many :images, :as => :for_object, :dependent => :destroy
  has_many :product_attributes, :dependent => :destroy
  has_many :product_model_attributes, :through => :product_attributes
  
  scope :for_buy, :conditions => {:for_buy => true}
  scope :for_sell, :conditions => {:for_sell => true}
  
  USING_CONDITIONS = {:poor => "Poor", :good => "Good", :flawless => "Flawless"}
  PRICE_RANGES = {3000 => "Below 3000", 
                  5000 => "3000 -> 5000",
                  7000 => "5000 -> 7000",
                  10000 => "7000 -> 10000",
                  19999 => "10000 -> 20000",
                  20000 => "Upper 20000"}
  PRICE_FIELDS = %w(honey_price price_for_good_type price_for_poor_type)
  PRICE_RANGE_SQLS = {3000 => PRICE_FIELDS.map{|f| "(#{f} > 0 AND #{f} <= 3000)"}.join(" OR "), 
                      5000 => PRICE_FIELDS.map{|f| "(#{f} >= 3000 AND #{f} <= 5000)"}.join(" OR "),
                      7000 => PRICE_FIELDS.map{|f| "(#{f} >= 5000 AND #{f} <= 7000)"}.join(" OR "),
                      10000 => PRICE_FIELDS.map{|f| "(#{f} >= 7000 AND #{f} <= 10000)"}.join(" OR "),
                      19999 => PRICE_FIELDS.map{|f| "(#{f} >= 10000 AND #{f} <= 20000)"}.join(" OR "),
                      20000 => PRICE_FIELDS.map{|f| "#{f} >= 20000"}.join(" OR ")
                      }
                      
  scope :price_range, lambda { |key| {:conditions => PRICE_RANGE_SQLS[key]} }
  
  after_save :expired_fragment_caches
  after_destroy :expired_fragment_caches

  def price_for(using_condition)
    return price_for_good_type if using_condition && using_condition == USING_CONDITIONS[:good]
    return price_for_poor_type if using_condition && using_condition == USING_CONDITIONS[:poor]
    return honey_price
  end

  def main_image_url(type)
    main_image.photo.url(type)
  end
  
  def has_flawless_type?
    honey_price && honey_price > 0.0 rescue false
  end
  def has_poor_type?
    price_for_poor_type && price_for_poor_type > 0.0 rescue false
  end
  def has_good_type?
    price_for_good_type && price_for_good_type > 0.0 rescue false
  end
  
  def using_condition_types
    result = []
    result << "Flawless" if has_flawless_type?
    result << "Poor" if has_poor_type?
    result << "Good" if has_good_type?
    result.join(" ")
  end
  
  def main_image
    return images.order("is_main DESC").first if images.count > 0
    return category.main_image if product_model.images.count == 0
    return product_model.main_image if self.product_model_attributes.count == 0

    ["Color", "Year", "Generation"].each do |attribut_key|
      cat_color_attr = self.category.category_attributes.find_by_title attribut_key
      color_attr_value = product_model_attributes.where(:category_attribute_id => cat_color_attr.id).first if cat_color_attr
  
      #return image based on color if it existed
      result_image = product_model.images.where("sum_attribute_names like ?", "%#{color_attr_value.value}%").first if color_attr_value
      return result_image if result_image
    end

    return product_model.main_image
  end

  def gen_attribute_filter_ids
    result = []
    self.product_model_attributes.each do |product_model_attribute|
      result << product_model_attribute.gen_fitler_id
    end
    prices = PRICE_RANGES.keys.sort
    prices.each_with_index do |price, index|
      if index == 0
        (result << "price_range_#{price}"; next) if honey_price && honey_price > 0 && honey_price <= price 
        (result << "price_range_#{price}"; next) if price_for_good_type && price_for_good_type > 0 && price_for_good_type <= price 
        (result << "price_range_#{price}"; next) if price_for_poor_type && price_for_poor_type > 0 && price_for_poor_type <= price 
      elsif index < prices.size - 1
        (result << "price_range_#{price}"; next) if honey_price && honey_price >= prices[index - 1] && honey_price <= price 
        (result << "price_range_#{price}"; next) if price_for_good_type && price_for_good_type >= prices[index - 1] && price_for_good_type <= price 
        (result << "price_range_#{price}"; next) if price_for_poor_type && price_for_poor_type >= prices[index - 1] && price_for_poor_type <= price
      else
        (result << "price_range_#{price}"; next) if honey_price && honey_price >= price 
        (result << "price_range_#{price}"; next) if price_for_good_type && price_for_good_type >= price 
        (result << "price_range_#{price}"; next) if price_for_poor_type && price_for_poor_type >= price
      end
    end
    result.join(" ")
  end
  
  def price_range_class(price_compare)
    prices = PRICE_RANGES.keys.sort
    prices.each_with_index do |price, index|
      if index == 0
        return "price_range_#{price}" if price_compare && price_compare > 0 && price_compare <= price 
      elsif index < prices.size - 1
        return "price_range_#{price}" if price_compare && price_compare >= prices[index - 1] && price_compare <= price 
      else
        return "price_range_#{price}" if price_compare && price_compare >= price 
      end
    end
    return ""
  end
  
  def expired_fragment_caches
    ActionController::Base.new.expire_fragment("homepage_container_category_#{self.product_model.category.id}_filter_attr") rescue nil
    ActionController::Base.new.expire_fragment("homepage_category_#{self.product_model.category.id}") rescue nil
    ActionController::Base.new.expire_fragment("homepage_product_container_category_#{self.product_model.category.id}") rescue nil
    ActionController::Base.new.expire_fragment("homepage_product_thumb_#{self.id}") rescue nil
  end
  
  def weight_lb
    product_model.weight_lb
  end
  
  rails_admin do
    
    list do
      field :title
      field :honey_price
      field :price_for_good_type
      field :price_for_poor_type
      field :for_sell
      field :for_buy
      field :category
      field :product_model
      field :images
    end
    export do
      field :title
      field :honey_price
      field :price_for_good_type
      field :price_for_poor_type
      field :for_sell
      field :for_buy
      field :category
      field :product_model
      field :images
      field :product_model_attributes
    end
    show do
      field :category
      field :product_model
      field :title
      field :honey_price
      field :price_for_good_type
      field :price_for_poor_type
      field :images
      field :product_attributes
    end
    edit do; end
    create do
      field :product_model
      field :title
      field :honey_price
      field :price_for_good_type
      field :price_for_poor_type
    end
    update do
      field :title
      field :honey_price
      field :price_for_good_type
      field :price_for_poor_type
      field :images
      field :product_attributes
    end
  end

end
