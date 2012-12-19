# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

admin = User.find_by_email 'admin@admin.com' rescue nil
admin = User.new(email: 'admin@admin.com', password: '123456', password_confirmation: '123456') unless admin
admin.save

categories = {'IPod' => ['iPod', 'iPod mini', 'iPod nano', 'iPod shuffle', 'iPod touch'], 
              'IPhone' => ['iPhone', '3G', '3GS', '4G', '4GS', '5G'],
              'Macbook' => [ 'Macbook', 'Macbook Pro', 'Macbook Air'] }
categories.keys.each do |category_title|
  #insert category
  category = Category.find_by_title category_title rescue nil
  category = Category.new(title: category_title, 
                          image_file_name: "/images/cat_#{category_title.downcase}.png", 
                          image_content_type: "png", image_file_size: 69570) unless category
  category.user = admin
  category.save
  
  #General Attribute
  ["Memory Space"].each do |title|
    attribute = category.category_attributes.find_by_title title rescue nil
    attribute = category.category_attributes.new(title: title, attribute_type: "Number") unless attribute
    attribute.save
  end
  mem_space_att = category.category_attributes.find_by_title "Memory Space"
  
  #insert product_models
  categories[category_title].each do |model_title|
    product_model = ProductModel.find_by_title model_title rescue nil
    product_model = ProductModel.new(title: model_title) unless product_model
    product_model.category = category
    product_model.save
    
    [8, 16, 32].each do |mem_space|
      att = product_model.product_model_attributes.find_by_value mem_space.to_s
      att = product_model.product_model_attributes.new(value: mem_space.to_s)
      att.category_attribute = mem_space_att
      att.save
    end
  end
  
  
end


