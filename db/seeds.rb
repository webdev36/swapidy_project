# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

admin = User.find_by_email 'admin@admin.com' rescue nil
admin = User.new(email: 'admin@admin.com', password: '123456', password_confirmation: '123456', is_admin: true) unless admin
admin.save

category_names = {"Galaxy" => "cat_galaxy.png", "iPad" => "cat_ipad.png", 
                  "iPhone" => "cat_iphone.png", "Macbook" => "cat_macbook.png", "iPod" => "cat_ipod.png"}
category_names.keys.each do |cat_name|
  category = Category.find_by_title cat_name rescue nil
  next if category
  category = Category.new(title: cat_name)
  category.user = admin
  category.save
  image = category.images.new(:is_main => true)
  image.photo = File.open("#{Rails.root}/demo_data/images/#{category_names[cat_name]}")
  image.save
end

# Insert Galaxy model and options
cat_galaxy = Category.find_by_title category_names[0]

model_names = {"Galaxy" => ["S II", "S III", "Note", "Note II"],
               "iPad" => ["iPad 2", "iPad 3", "iPad 4", "Mini"],
               "iPhone" => ["iPhone 4", "iPhone 4S", "iPhone 5"],
               "Macbook" => ["Macbook", "Macbook Pro", "Macbook Air"],
               "iPod" => ["Touch", "Nano", "Classic"]}
model_names.keys.each do |cat_name|
  category = Category.find_by_title cat_name
  model_names[cat_name].each do |model_name|
    model = category.product_models.find_by_title model_name rescue nil
    next if model
    category.product_models.create(:title => model_name)
  end
end

def create_product_model_attr(category_attribute, model, value) 
  new_attr = category_attribute.product_model_attributes.new(:value => value)
  new_attr.product_model = model
  new_attr.save
end 

#Set attribute Memory Space
["Galaxy", "iPad", "iPhone", "iPod"].each do |cat_name|
  category = Category.find_by_title cat_name
  category_attribute = category.category_attributes.create(:title => "Memory Space", :attribute_type => "String")
  
  category.product_models.each do |model|
    if ["iPhone 4", "Touch", "Nano"].include?(model.title)
      create_product_model_attr(category_attribute, model, "8GB")
    end
    
    if(["Galaxy", "iPad", "iPhone"].include?(category.title) || 
        ["Touch", "Nano"].include?(model.title))
      create_product_model_attr(category_attribute, model, "16GB")
    end

    if(["Galaxy", "iPad", "iPhone"].include?(category.title) || 
        ["Touch"].include?(model.title))
      create_product_model_attr(category_attribute, model, "32GB")
    end

    if(["Classic"].include?(model.title))
      create_product_model_attr(category_attribute, model, "30GB")
    end

    if(category.title == "iPad" ||
        ["iPhone 4S", "iPhone 5", "Touch"].include?(model.title) )
      create_product_model_attr(category_attribute, model, "64GB")
    end
    
    if model.title == "Classic"
      create_product_model_attr(category_attribute, model, "60GB")
      create_product_model_attr(category_attribute, model, "80GB")
      create_product_model_attr(category_attribute, model, "120GB")
      create_product_model_attr(category_attribute, model, "160GB")
    end
  end
end

#Set attribute Network
["Galaxy", "iPhone"].each do |cat_name|
  category = Category.find_by_title cat_name
  category_attribute = category.category_attributes.create(:title => "Network", :attribute_type => "String")
  
  category.product_models.each do |model|
    create_product_model_attr(category_attribute, model, "AT&T")
    create_product_model_attr(category_attribute, model, "T-Mobile")
    create_product_model_attr(category_attribute, model, "Sprint")
    create_product_model_attr(category_attribute, model, "Factory Unlocked")
  end
end


#Set attribute Color
["Galaxy", "iPad", "iPhone"].each do |cat_name|
  category = Category.find_by_title cat_name
  category_attribute = category.category_attributes.create(:title => "Color", :attribute_type => "String")
  
  category.product_models.each do |model|  
    create_product_model_attr(category_attribute, model, "White")
    if model.title != "Note" && model.title != "Note II"
      create_product_model_attr(category_attribute, model, "Black")
    end
    
    if model.title == "S III"
      create_product_model_attr(category_attribute, model, "Brown")
      create_product_model_attr(category_attribute, model, "Red")
    end
    
    if model.title == "S III" && model.title == "Note"
      create_product_model_attr(category_attribute, model, "Blue")
    end
    if model.title == "Note 2"
      create_product_model_attr(category_attribute, model, "Gray")
    end
  end
end

model_image_text = %Q{Galaxy | S II | White | /Galaxy/s2_white.png
Galaxy | S II | Black | Galaxy/s2_black.png
Galaxy | S III | White | Galaxy/s3_white.png
Galaxy | S III | Black | Galaxy/s3_black.png
Galaxy | S III | Brown | Galaxy/s3_brown.png
Galaxy | S III | Blue | Galaxy/s3_blue.png
Galaxy | S III | Red | Galaxy/s3_red.png
Galaxy | Note | White | Galaxy/note_white.png
Galaxy | Note | Blue | Galaxy/note_blue.png
Galaxy | Note 2 | White | Galaxy/note2_white.png
Galaxy | Note 2 | Gray | Galaxy/note2_gray.png
iPhone | iPhone 4 | White | iPhone/4_white.png
iPhone | iPhone 4 | Black | iPhone/4_black.png
iPhone | iPhone 4S | White | iPhone/4s_white.png
iPhone | iPhone 4S | Black | iPhone/4s_black.png
iPhone | iPhone 5 | White | iPhone/5_white.png
iPhone | iPhone 5 | Black | iPhone/5_black.png
iPad | Mini | White | iPad/mini_white.png
iPad | Mini | Black | iPad/mini_black.png
iPad | iPad 2 | Black | iPad/2_black.png
iPad | iPad 2 | White | iPad/2_white.png
iPad | iPad 3 | Black | iPad/3_black.png
iPad | iPad 3 | White | iPad/3_white.png
iPad | iPad 4 | Black | iPad/4_black.png
iPad | iPad 4 | White | iPad/4_white.png
Macbook | Macbook Pro | 2010 | Macbook/pro/2010.png
Macbook | Macbook Pro | 2011 | Macbook/pro/2011.png
Macbook | Macbook Pro | 2012 | Macbook/pro/2012.png
Macbook | Macbook Air | 2010 | Macbook/air/2010.png
Macbook | Macbook Air | 2011 | Macbook/air/2011.png
Macbook | Macbook Air | 2012 | Macbook/air/2012.png
iPod | Touch | 2 | iPod/touch/2.png
iPod | Touch | 3 | iPod/touch/3.png
iPod | Touch | 4 | iPod/touch/4.png
iPod | Touch | 5 | iPod/touch/5.png
iPod | Nano | 5 | iPod/nano/5.png
iPod | Nano | 6 | iPod/nano/6.png
iPod | Nano | 7 | iPod/nano/7.png
iPod | Classic | 5 | iPod/classic/5.png
iPod | Classic | 6 | iPod/classic/6.png
}

lines = model_image_text.split(/\n/)
lines.each do |line|
  parts = line.split(/ \| /)
  category = Category.find_by_title parts[0].strip
  next unless category
  model = category.product_models.find_by_title parts[1].strip
  next unless model
  
  if(["Galaxy", "iPhone", "iPad"].include?(parts[0].strip))
    cat_attr = category.category_attributes.find_by_title "Color"
    attr = model.product_model_attributes.where(:category_attribute_id => cat_attr.id, :value => parts[2].strip ).first
    next unless attr
    image = model.images.new(:sum_attribute_names => attr.value)
    image.photo = File.open("#{Rails.root}/demo_data/images/#{parts.last.strip}")
    image.save
  end
  
  if(["iPod"].include?(parts[0].strip))
    cat_attr = category.category_attributes.find_by_title "Generation"
    attr = model.product_model_attributes.where(:category_attribute_id => cat_attr.id, :value => parts[2].strip ).first
    next unless attr
    image = model.images.new(:sum_attribute_names => attr.value)
    image.photo = File.open("#{Rails.root}/demo_data/images/#{parts.last.strip}")
    image.save
  end
  
  #if(["Macbook"].include?(parts[0].strip))
  #  cat_attr = category.category_attributes.find_by_title "Year"
  #  attr = model.product_model_attributes.where(:category_attribute_id => cat_attr.id, :value => parts[2].strip ).first
  #  next unless attr
  #  image = model.images.new(:sum_attribute_names => attr.value)
  #  image.photo = File.open("#{Rails.root}/demo_data/images/#{parts.last.strip}")
  #  image.save
  #end
end
