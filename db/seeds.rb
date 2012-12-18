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

['IPod', 'IPhone', 'Macbook'].each do |category_title|
  ipod_category = Category.new(title: category_title, image_file_name: "/images/cat_#{category_title.downcase}.png", image_content_type: "png", image_file_size: 69570)
  ipod_category.user = admin
  ipod_category.save
end
