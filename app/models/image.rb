class Image < ActiveRecord::Base
  attr_accessible :title, :sum_attribute_names, :is_main, :for_object_id, :for_object_type, :photo

  has_attached_file :photo, :styles => {:thumb => "150x150>", :medium => "200x200>", :large => "250x250>"}, :default_url => '/images/default_cat_:style.png'

  belongs_to :for_object, :polymorphic => true
  
  scope :main, :conditions => {:is_main => true}
  
  def is_main?
    is_main
  end
  
      
  after_save :expired_fragment_caches
  after_destroy :expired_fragment_caches
  
  def expired_fragment_caches
    self.for_object.expired_fragment_caches rescue nil
  end

end
