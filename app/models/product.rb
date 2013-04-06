class Product < ActiveRecord::Base

  attr_accessible :title, :price_for_sell, :product_model_id, :image_ids, :for_sell, :for_buy,
                  :product_attribute_ids, :product_model_attribute_ids, :price_for_good_sell, :price_for_poor_sell ,:upload_database_id
  
  has_attached_file :image, :styles => {:thumb => "50x50>", :medium => "200x200>"}
  
  belongs_to :user
  belongs_to :category
  belongs_to :product_model
  belongs_to :upload_database
  
  has_many :images, :as => :for_object, :dependent => :destroy
  has_many :product_attributes, :dependent => :destroy
  has_many :product_model_attributes, :through => :product_attributes
  
  scope :for_buy, :conditions => ["swap_type = 2"]
  scope :for_sell, :conditions => ["swap_type = 1"]
  scope :for_sell_only, :conditions => ["swap_type = 3"]

  SWAP_TYPES = {0 => "Sell and Buy", 1 => "Sell", 2 => "Buy", 3 => "Sell Only"}
  
  USING_CONDITIONS = {:poor => "Poor", :good => "Good", :flawless => "Flawless"}
  PRICE_RANGES = {300 => "Below 300", 
                  500 => "300 -> 500",
                  700 => "500 -> 700",
                  1000 => "700 -> 1000",
                  1999 => "1000 -> 2000",
                  2000 => "Upper 2000"}
  SELL_PRICE_FIELDS = %w(price_for_sell price_for_good_sell price_for_poor_sell)
  SELL_PRICE_RANGE_SQLS = {300 => SELL_PRICE_FIELDS.map{|f| "(#{f} > 0 AND #{f} <= 300)"}.join(" OR "), 
                          500 => SELL_PRICE_FIELDS.map{|f| "(#{f} >= 300 AND #{f} <= 500)"}.join(" OR "),
                          700 => SELL_PRICE_FIELDS.map{|f| "(#{f} >= 500 AND #{f} <= 700)"}.join(" OR "),
                          1000 => SELL_PRICE_FIELDS.map{|f| "(#{f} >= 700 AND #{f} <= 1000)"}.join(" OR "),
                          1999 => SELL_PRICE_FIELDS.map{|f| "(#{f} >= 1000 AND #{f} <= 2000)"}.join(" OR "),
                          2000 => SELL_PRICE_FIELDS.map{|f| "#{f} >= 2000"}.join(" OR ")
                          }
  BUY_PRICE_FIELDS = %w(price_for_buy price_for_good_buy price_for_poor_buy)
  BUY_PRICE_RANGE_SQLS = {300 => BUY_PRICE_FIELDS.map{|f| "(#{f} > 0 AND #{f} <= 300)"}.join(" OR "), 
                          500 => BUY_PRICE_FIELDS.map{|f| "(#{f} >= 300 AND #{f} <= 500)"}.join(" OR "),
                          700 => BUY_PRICE_FIELDS.map{|f| "(#{f} >= 500 AND #{f} <= 700)"}.join(" OR "),
                          1000 => BUY_PRICE_FIELDS.map{|f| "(#{f} >= 700 AND #{f} <= 1000)"}.join(" OR "),
                          1999 => BUY_PRICE_FIELDS.map{|f| "(#{f} >= 1000 AND #{f} <= 2000)"}.join(" OR "),
                          2000 => BUY_PRICE_FIELDS.map{|f| "#{f} >= 2000"}.join(" OR ")
                          }
                          
  scope :price_range, lambda { |key, for_what| {:conditions => for_what && for_what == :for_sell ? SELL_PRICE_RANGE_SQLS[key] : BUY_PRICE_RANGE_SQLS[key]} }
  
  before_save :set_auto_value_fields
  after_save :expired_fragment_caches
  after_destroy :expired_fragment_caches

  def price_for(using_condition)
    return price_for_good_sell if using_condition && using_condition == USING_CONDITIONS[:good]
    return price_for_poor_sell if using_condition && using_condition == USING_CONDITIONS[:poor]
    return price_for_sell
  end

  def main_image_url(type)
    main_image.photo.url(type)
  end
  
  def has_flawless_sell?
    price_for_sell && price_for_sell > 0.0 rescue false
  end
  def has_poor_sell?
    price_for_poor_sell && price_for_poor_sell > 0.0 rescue false
  end
  def has_good_sell?
    price_for_good_sell && price_for_good_sell > 0.0 rescue false
  end
  
  def has_flawless_buy?
    price_for_buy && price_for_buy > 0.0 rescue false
  end
  def has_poor_buy?
   price_for_poor_buy && price_for_poor_buy > 0.0 rescue false
  end
  def has_good_buy?
    price_for_good_buy && price_for_good_buy > 0.0 rescue false
  end
  
  def flaw_less_name(for_type = :for_sell)
    for_type == :for_buy ? "Brand new with warranty" : "Flawless"
  end
  
  def sell_prices
    "#{has_flawless_sell? ? price_for_sell: "-" }/#{has_good_sell? ? price_for_good_sell : "-"}/#{has_poor_sell? ? price_for_poor_sell : "-"}"
  end
  def buy_prices
    "#{has_flawless_buy? ? price_for_buy: "-" }/#{has_good_buy? ? price_for_good_buy : "-"}/#{has_poor_buy? ? price_for_poor_buy : "-"}"
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
      result << product_model_attribute.gen_filter_id
    end
    prices = PRICE_RANGES.keys.sort
    prices.each_with_index do |price, index|
      if index == 0
        (result << "price_range_#{price}"; next) if price_for_sell && price_for_sell > 0 && price_for_sell <= price        
        (result << "price_range_#{price}"; next) if price_for_buy && price_for_buy > 0 && price_for_buy <= price 

#        (result << "price_range_#{price}"; next) if price_for_good_sell && price_for_good_sell > 0 && price_for_good_sell <= price 
#        (result << "price_range_#{price}"; next) if price_for_poor_sell && price_for_poor_sell > 0 && price_for_poor_sell <= price 
      elsif index < prices.size - 1
        (result << "price_range_#{price}"; next) if price_for_sell && price_for_sell >= prices[index - 1] && price_for_sell <= price 
        (result << "price_range_#{price}"; next) if price_for_good_sell && price_for_good_sell >= prices[index - 1] && price_for_good_sell <= price 
        (result << "price_range_#{price}"; next) if price_for_poor_sell && price_for_poor_sell >= prices[index - 1] && price_for_poor_sell <= price        
        
        (result << "price_range_#{price}"; next) if price_for_buy && price_for_buy >= prices[index - 1] && price_for_buy <= price 
      else
        (result << "price_range_#{price}"; next) if price_for_sell && price_for_sell >= price 
        (result << "price_range_#{price}"; next) if price_for_good_sell && price_for_good_sell >= price 
        (result << "price_range_#{price}"; next) if price_for_poor_sell && price_for_poor_sell >= price
        
        (result << "price_range_#{price}"; next) if price_for_buy && price_for_buy >= price 
      end
    end

    result << "sell_only" if for_sells_only?
    result << "sell" if for_sells?
    result << "buy" if for_buys?
    result << "both" if for_sells? || for_buys?
    
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
  
  def for_buys?
    #self.has_flawless_buy? || self.has_poor_buy? || self.has_good_buy?
    self.swap_type == 2 ? true : false
  end
  
  def for_sells?    
    #(self.has_flawless_sell? || self.has_poor_sell? || self.has_good_sell?) && self.swap_type != 3
    self.swap_type == 1 ? true : false
  end
  def for_sells_only?
    self.swap_type == 3 ? true : false
  end
  def set_auto_value_fields
    self.category = self.product_model.category if self.product_model
    self.swap_type = (for_buys? && for_sells?) ? 0 : (for_buys? ? 2 : (for_sells? ? 1 : 3))
  end
  def get_shop_type
    SWAP_TYPES[self.swap_type].downcase.tr(" ", "-")
  end
  def weight_lb
    product_model.weight_lb
  end
  
end


