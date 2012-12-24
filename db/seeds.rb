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

category_names = {"Galaxy" => "cat_galaxy.png", "iPad" => "cat_ipad.png", 
                  "iPhone" => "cat_iphone.png", "Macbook" => "cat_macbook.png", "iPod" => "cat_ipod.png"}
category_names.keys.each do |cat_name|
  category = Category.find_by_title cat_name rescue nil
  next if category
  category = Category.new(title: cat_name) 
  category.image = File.open("#{Rails.root}/demo_data/images/#{category_names[cat_name]}")
  category.user = admin
  category.save
end

# Insert Galaxy model and options
cat_galaxy = Category.find_by_title category_names[0]

model_names = {"Galaxy" => ["S II", "S III", "Note", "Note II"],
               "iPad" => ["iPad 2", "iPad 3", "iPad 4", "Mini"],
               "iPhone" => ["iPhone 4", "iPhone 4S", "iPhone 5"],
               "Macbook" => ["Macbook", "Macbook Pro", "Macbook Air"],
               "iPod" => ["Touch 2", "Touch 3", "Touch 4", "Touch 5", "Nano 5", "Nano 6", "Nano 7", "Classic 5", "Classic U2", "Classic 6"]}
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
  attr_network_type = category.category_attributes.create(:title => "Memory Space", :attribute_type => "String")
  
  category.product_models.each do |model|
    if ["iPhone 4", "Touch 2", "Touch 4", "Nano 5"].include?(model.title)
      create_product_model_attr(attr_network_type, model, "8GB")
    end
    
    if(["Galaxy", "iPad", "iPhone"].include?(category.title) || 
        ["Touch 2", "Nano 5", "Nano 6", "Nano 7"].include?(model.title))
      create_product_model_attr(attr_network_type, model, "16GB")
    end

    if(["Galaxy", "iPad", "iPhone"].include?(category.title) || 
        ["Touch 2", "Touch 3", "Touch 4", "Touch 5"].include?(model.title))
      create_product_model_attr(attr_network_type, model, "32GB")
    end

    if(["Classic 5", "Classic U2"].include?(model.title))
      create_product_model_attr(attr_network_type, model, "30GB")
    end

    if(category.title == "iPad" ||
        ["iPhone 4S", "iPhone 5", "Touch 3", "Touch 4", "Touch 5"].include?(model.title) )
      create_product_model_attr(attr_network_type, model, "64GB")
    end

    if(["Classic 5"].include?(model.title) )
      create_product_model_attr(attr_network_type, model, "60GB")
    end

    if(["Classic 5", "Classic 6"].include?(model.title) )
      create_product_model_attr(attr_network_type, model, "80GB")
    end
    
    if model.title == "Classic 6"
      create_product_model_attr(attr_network_type, model, "120GB")
      create_product_model_attr(attr_network_type, model, "160GB")
    end
    
  end

end

#Set attribute Network
["Galaxy", "iPhone"].each do |cat_name|
  category = Category.find_by_title cat_name
  attr_network_type = category.category_attributes.create(:title => "Network", :attribute_type => "String")
  
  category.product_models.each do |model|
    create_product_model_attr(attr_network_type, model, "AT&T")
    create_product_model_attr(attr_network_type, model, "T-Mobile")
    create_product_model_attr(attr_network_type, model, "Sprint")
    create_product_model_attr(attr_network_type, model, "Factory Unlocked")
  end
end

#Set attribute Network for iPad
["iPad"].each do |cat_name|
  category = Category.find_by_title cat_name
  attr_network_type = category.category_attributes.create(:title => "Network Type", :attribute_type => "String")
  
  category.product_models.each do |model|
    create_product_model_attr(attr_network_type, model, "WiFi Only")

    if model.title == "iPad 2"
      create_product_model_attr(attr_network_type, model, "3G - AT&T")
      create_product_model_attr(attr_network_type, model, "3G - Verizon")
    end
    
    if ["iPad 3", "iPad 4", "Mini"].include?(model.title)
      create_product_model_attr(attr_network_type, model, "4G LTE - AT&T")
      create_product_model_attr(attr_network_type, model, "4G LTE - Verizon")
    end
    
    if ["iPad 4", "Mini"].include?(model.title)
      create_product_model_attr(attr_network_type, model, "4G LTE - Sprint")
    end
  end
end

#Set attribute Color
["Galaxy", "iPad", "iPhone"].each do |cat_name|
  category = Category.find_by_title cat_name
  attr_network_type = category.category_attributes.create(:title => "Color", :attribute_type => "String")
  
  category.product_models.each do |model|  
    create_product_model_attr(attr_network_type, model, "White")
    if model.title != "Note" && model.title != "Note II"
      create_product_model_attr(attr_network_type, model, "Black")
    end
    
    if model.title == "S III"
      create_product_model_attr(attr_network_type, model, "Blue")
      create_product_model_attr(attr_network_type, model, "Brown")
      create_product_model_attr(attr_network_type, model, "Red")
    end
  end
end

#
product_text = %Q{Galaxy | S II | AT&T | 16GB
Galaxy | S II | AT&T | 32GB
Galaxy | S II | T-Mobile | 16GB
Galaxy | S II | T-Mobile | 32GB
Galaxy | S II | Sprint | 16GB
Galaxy | S II | Sprint | 32GB
Galaxy | S II | Factory Unlocked | 16GB
Galaxy | S III | AT&T | 16GB
Galaxy | S III | AT&T | 32GB
Galaxy | S III | T-Mobile | 16GB
Galaxy | S III | T-Mobile | 32GB
Galaxy | S III | Verizon | 16GB
Galaxy | S III | Verizon | 32GB
Galaxy | S III | Sprint | 16GB
Galaxy | S III | Sprint | 32GB
Galaxy | S III | Factory Unlocked | 16GB 
Galaxy | S III | Factory Unlocked | 32GB
Galaxy | Note | AT&T | 16GB
Galaxy | Note | T-Mobile | 16GB
Galaxy | Note | Factory Unlocked | 16GB
Galaxy | Note | Factory Unlocked | 32GB
Galaxy | Note II | AT&T | 16GB
Galaxy | Note II | T-Mobile | 16GB
Galaxy | Note II | Verizon | 16GB
Galaxy | Note II | Sprint | 16GB
Galaxy | Note II | Factory Unlocked | 16GB
Galaxy | Note II | Factory Unlocked | 32GB}

product_text += %Q{
iPad | iPad 2 | WiFi Only | 16GB
iPad | iPad 2 | WiFi Only | 32GB
iPad | iPad 2 | WiFi Only | 64GB
iPad | iPad 2 | 3G - AT&T | 16GB
iPad | iPad 2 | 3G - AT&T | 32GB
iPad | iPad 2 | 3G - AT&T | 64GB
iPad | iPad 2 | 3G - Verizon | 16GB
iPad | iPad 2 | 3G - Verizon | 32GB
iPad | iPad 2 | 3G - Verizon | 64GB
iPad | iPad 3 | WiFi Only | 16GB
iPad | iPad 3 | WiFi Only | 32GB
iPad | iPad 3 | WiFi Only | 64GB
iPad | iPad 3 | 4G LTE - AT&T | 16GB
iPad | iPad 3 | 4G LTE - AT&T | 32GB
iPad | iPad 3 | 4G LTE - AT&T | 64GB
iPad | iPad 3 | 4G LTE - Verizon | 16GB
iPad | iPad 3 | 4G LTE - Verizon | 32GB
iPad | iPad 3 | 4G LTE - Verizon | 64GB
iPad | iPad 4 | WiFi Only | 16GB
iPad | iPad 4 | WiFi Only | 32GB
iPad | iPad 4 | WiFi Only | 64GB
iPad | iPad 4 | 4G LTE - AT&T | 16GB
iPad | iPad 4 | 4G LTE - AT&T | 32GB
iPad | iPad 4 | 4G LTE - AT&T | 64GB
iPad | iPad 4 | 4G LTE - Sprint | 16GB
iPad | iPad 4 | 4G LTE - Sprint | 32GB
iPad | iPad 4 | 4G LTE - Sprint | 64GB
iPad | iPad 4 | 4G LTE - Verizon | 16GB
iPad | iPad 4 | 4G LTE - Verizon | 32GB
iPad | iPad 4 | 4G LTE - Verizon | 64GB
iPad | Mini | WiFi Only | 16GB
iPad | Mini | WiFi Only | 32GB
iPad | Mini | WiFi Only | 64GB
iPad | Mini | 4G LTE - AT&T | 16GB
iPad | Mini | 4G LTE - AT&T | 32GB
iPad | Mini | 4G LTE - AT&T | 64GB
iPad | Mini | 4G LTE - Sprint | 16GB
iPad | Mini | 4G LTE - Sprint | 32GB
iPad | Mini | 4G LTE - Sprint | 64GB
iPad | Mini | 4G LTE - Verizon | 16GB
iPad | Mini | 4G LTE - Verizon | 32GB
iPad | Mini | 4G LTE - Verizon | 64GB}

product_text += %Q{iPhone | iPhone 4 | AT&T | 8GB 
iPhone | iPhone 4 | AT&T | 16GB
iPhone | iPhone 4 | AT&T | 32GB
iPhone | iPhone 4 | Sprint | 8GB
iPhone | iPhone 4 | Verizon | 8GB
iPhone | iPhone 4 | Verizon | 16GB
iPhone | iPhone 4 | Verizon | 32GB
iPhone | iPhone 4 | Factory Unlocked | 8GB 
iPhone | iPhone 4 | Factory Unlocked | 16GB
iPhone | iPhone 4 | Factory Unlocked | 32GB
iPhone | iPhone 4S | AT&T | 16GB 
iPhone | iPhone 4S | AT&T | 32GB
iPhone | iPhone 4S | AT&T | 64GB
iPhone | iPhone 4S | Sprint | 16GB
iPhone | iPhone 4S | Sprint | 32GB 
iPhone | iPhone 4S | Sprint | 64GB
iPhone | iPhone 4S | Verizon | 16GB
iPhone | iPhone 4S | Verizon | 32GB
iPhone | iPhone 4S | Verizon | 64GB
iPhone | iPhone 4S | Factory Unlocked | 16GB 
iPhone | iPhone 4S | Factory Unlocked | 32GB
iPhone | iPhone 4S | Factory Unlocked | 64GB
iPhone | iPhone 5 | AT&T | 16GB 
iPhone | iPhone 5 | AT&T | 32GB
iPhone | iPhone 5 | AT&T | 64GB
iPhone | iPhone 5 | Sprint | 16GB
iPhone | iPhone 5 | Sprint | 32GB 
iPhone | iPhone 5 | Sprint | 64GB
iPhone | iPhone 5 | Verizon | 16GB
iPhone | iPhone 5 | Verizon | 32GB
iPhone | iPhone 5 | Verizon | 64GB
iPhone | iPhone 5 | Factory Unlocked | 16GB 
iPhone | iPhone 5 | Factory Unlocked | 32GB
iPhone | iPhone 5 | Factory Unlocked | 64GB}

lines = product_text.split(/\n/)
lines.each do |line|
  parts = line.split(/ \| /)
  category = Category.find_by_title parts[0].strip
  next unless category
  model = category.product_models.find_by_title parts[1].strip
  next unless model
  
  cat_network_attr = category.category_attributes.find_by_title(parts[0].strip == "iPad" ? "Network Type" : "Network")
  network_attribute = model.product_model_attributes.where(:category_attribute_id => cat_network_attr.id, :value => parts[2].strip).first
  next unless network_attribute

  cat_memory_attr = category.category_attributes.find_by_title "Memory Space"
  memory_attribute = model.product_model_attributes.where(:category_attribute_id => cat_memory_attr.id, :value => parts[3].strip).first
  next unless memory_attribute
  
  cat_color_attr = category.category_attributes.find_by_title "Color"
  color_attributes = model.product_model_attributes.where(:category_attribute_id => cat_color_attr.id)
  color_attributes.each do |color_attribute|
    Product::USING_CONDITIONS.values.each do |condition|
      if parts[0].strip == "Galaxy"
        product_title = parts.join(" - ") + " #{color_attribute.value} (#{condition})"
      else
        product_title = parts.last(parts.length - 1).join(" - ") + " #{color_attribute.value} (#{condition})"
      end

      product = Product.new(:title => product_title, :using_condition => condition, :honey_price => 100)
      product.category = category
      product.product_model = model
      product.save

      attr = product.product_attributes.new
      attr.product_model_attribute = color_attribute
      attr.save
      
      attr = product.product_attributes.new
      attr.product_model_attribute = memory_attribute
      attr.save

      if(parts[0].strip != "iPod")
        attr = product.product_attributes.new
        attr.product_model_attribute = network_attribute
        attr.save
      end
    end
  end
end


product_text = %Q{iPod | Touch 2 | 8GB
iPod | Touch 2 | 16GB
iPod | Touch 2 | 32GB
iPod | Touch 3 | 32GB
iPod | Touch 3 | 64GB
iPod | Touch 4 | 8GB
iPod | Touch 4 | 32GB
iPod | Touch 4 | 64GB
iPod | Touch 5 | 32GB
iPod | Touch 5 | 64GB
iPod | Nano 5 | 8GB
iPod | Nano 5 | 16GB
iPod | Nano 6 | 16GB
iPod | Nano 6 | 8GB
iPod | Nano 6 | 16GB
iPod | Nano 7 | 16GB
iPod | Classic 5 | 30GB
iPod | Classic U2 | 30GB
iPod | Classic 5 | 60GB
iPod | Classic 5 | 80GB
iPod | Classic 6 | 80GB
iPod | Classic 6 | 120GB
iPod | Classic 6 | 160GB}

lines = product_text.split(/\n/)
lines.each do |line|
  parts = line.split(/ \| /)
  category = Category.find_by_title parts[0].strip
  next unless category
  model = category.product_models.find_by_title parts[1].strip
  next unless model

  cat_memory_attr = category.category_attributes.find_by_title "Memory Space"
  memory_attribute = model.product_model_attributes.where(:category_attribute_id => cat_memory_attr.id, :value => parts[2].strip).first
  next unless memory_attribute

  Product::USING_CONDITIONS.values.each do |condition|
    product_title = parts.join(" - ") + " (#{condition})"
    
    product = Product.new(:title => product_title, :using_condition => condition, :honey_price => 100)
    product.category = category
    product.product_model = model
    product.save
    
    attr = product.product_attributes.new
    attr.product_model_attribute = memory_attribute
    attr.save
  end
end
