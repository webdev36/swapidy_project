class Product < ActiveRecord::Base

  attr_accessible :title, :using_condition, :honey_price, :product_model_id, :image_ids, :for_sell, :for_buy,
                  :product_attribute_ids, :product_model_attribute_ids
  
  has_attached_file :image, :styles => {:thumb => "50x50>", :medium => "200x200>"}
  
  belongs_to :user
  belongs_to :category
  belongs_to :product_model

  has_many :product_attributes
  has_many :product_model_attributes, :through => :product_attributes
  
  USING_CONDITIONS = {:poor => "Poor", :good => "Good", :flawless => "Flawless"}
  
  validates :honey_price, :using_condition, :presence => true
  validate :conditions_for_buy_contrains
  
  has_many :images, :as => :for_object

  after_save :expired_fragment_caches
  after_destroy :expired_fragment_caches

  def main_image_url(type)
    main_image.photo.url(type)
  end
  
  def main_image
    return (images.where(:is_main => true).first || images.first) if images.count > 0
    return category.main_image if product_model.images.count == 0
    return product_model.main_image if self.product_model_attributes.count == 0

    cat_color_attr = self.category.category_attributes.find_by_title "Color"
    color_attr_value = product_model_attributes.where(:category_attribute_id => cat_color_attr.id).first if cat_color_attr

    #return image based on color if it existed
    result_image = product_model.images.find(:first, :conditions => ["sum_attribute_names like ?", "%#{color_attr_value.value}%"]) if color_attr_value
    return result_image if result_image

    #return images with nearly same attributes 
    cond_params = product_model_attributes.map{|a| a.value}
    sql = cond_params.map{|attr_value| "(sum_attribute_names like ? )"}.join(" AND ")
    like_image = product_model.images.find(:first, :conditions => ( [sql] + cond_params.map{|p| "%#{p}%" })) unless cond_params.empty?

    return like_image || product_model.main_image
  end

  def gen_attribute_names
    result = []
    self.product_model_attributes.each do |product_model_attribute|
      result << product_model_attribute.value
    end
    result.join(" ")
  end
  
  def expired_fragment_caches
    ActionController::Base.new.expire_fragment("homepage_container_category_#{self.category.id}") rescue nil
    ActionController::Base.new.expire_fragment("homepage_product_container_category_#{self.category.id}") rescue nil
    ActionController::Base.new.expire_fragment("homepage_product_thumb_#{self.id}") rescue nil
  end
  
  def weight_lb
    product_model.weight_lb
  end
  
  def conditions_for_buy_contrains
    if for_buy && using_condition && using_condition != USING_CONDITIONS[:flawless]
      errors.add(:for_buy, "could not allow when it is not Flawless") 
      return false
    end
    return true
  end
  
  def self.import_from_textline(textline)
    
    parts = textline.split(/ \| /)
    return if parts.size < 3
    
    category = Category.find_by_title parts[0].strip
    return nil unless category
    
    model = category.product_models.find_by_title parts[1].strip
    return nil unless model
  
    product = Product.new(:title => parts.last, :using_condition => Product::USING_CONDITIONS[:flawless], :honey_price => 100)
    product.category = category
    product.product_model = model
    parts.each_with_index do |attribute_text, index|
      next if index < 2 || index == (parts.size - 1)
      attr_str_pair = attribute_text.split(/\: /)
      next if attr_str_pair.size != 2 
      attr_key = attr_str_pair[0].strip
      attr_value = attr_str_pair[1].strip
      if attr_key == "Condition"
        product.using_condition = attr_value
      elsif attr_key == "Price"
        product.honey_price = attr_value.to_f
      else
        cat_attr = category.category_attributes.find_by_title attr_key
        unless cat_attr
          cat_attr = category.category_attributes.new
          cat_attr.title = attr_key
        end
        
        model_attr_value = model.product_model_attributes.where(:category_attribute_id => cat_attr.id, :value => attr_value).first
        unless model_attr_value
          model_attr_value = model.product_model_attributes.new
          model_attr_value.category_attribute = cat_attr
          model_attr_value.value = attr_value
        end
        attr = product.product_attributes.new
        attr.product_model_attribute = model_attr_value
      end
    end

    return product if product.save
  end

  rails_admin do
    configure :using_condition, :enum do
      enum do
        Product::USING_CONDITIONS.keys.map {|key| [Product::USING_CONDITIONS[key], Product::USING_CONDITIONS[key]]}
      end
    end
    
    list do
      field :title
      field :honey_price
      field :using_condition
      field :category
      field :product_model
      field :images
    end
    export do; end
    show do
      field :category
      field :product_model
      field :title
      field :honey_price
      field :using_condition
      field :images
      field :product_attributes
    end
    edit do; end
    create do
      field :product_model
      field :title
      field :honey_price
      field :using_condition
    end
    update do
      field :title
      field :honey_price
      field :using_condition
      field :images
      field :product_attributes
    end
  end

end
