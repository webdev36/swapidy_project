class Image < ActiveRecord::Base
  attr_accessible :title, :sum_attribute_names, :is_main

  has_attached_file :photo, :styles => {:thumb => "100x100>", :medium => "150x150>", :large => "200x200>"}, :default_url => '/images/default_cat_:style.png'

  belongs_to :for_object, :polymorphic => true
  
  scope :main, :conditions => {:is_main => true}
  
  def is_main?
    is_main
  end
  
end
