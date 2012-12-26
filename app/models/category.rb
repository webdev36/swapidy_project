class Category < ActiveRecord::Base
  attr_accessible :title, :image_file_name, :image_content_type, :image_file_size
  
  belongs_to :user
  has_many :products
  has_many :product_models
  has_many :category_attributes
  has_many :images, :as => :for_object, :class_name => "Image"

  def main_image_url(type)
    main_image.photo.url(type)
  end
  
  def main_image
    images.where(:is_main => true).first || self.images.first || images.new
  end

  after_save :expired_fragment_caches
  after_destroy :expired_fragment_caches_for_destroy

  def expired_fragment_caches
    ActionController::Base.new.expire_fragment("homepage_available_categories")
  end  
  
  private
    
    def expired_fragment_caches_for_destroy
      expired_fragment_caches
      ActionController::Base.new.expire_fragment("homepage_container_category_#{category.id}")
    end
end
