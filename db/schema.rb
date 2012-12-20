# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121220100653) do

  create_table "categories", :force => true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
  end

  create_table "category_attributes", :force => true do |t|
    t.integer  "category_id"
    t.string   "attribute_type"
    t.string   "title"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "category_attributes", ["category_id"], :name => "index_category_attributes_on_category_id"

  create_table "comments", :force => true do |t|
    t.string   "commenter"
    t.text     "body"
    t.integer  "post_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "comments", ["post_id"], :name => "index_comments_on_post_id"

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"

  create_table "product_attributes", :force => true do |t|
    t.integer  "product_id"
    t.integer  "product_model_attribute_id"
    t.string   "value"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "product_attributes", ["product_model_attribute_id"], :name => "index_product_attributes_on_product_model_attribute_id"

  create_table "product_model_attributes", :force => true do |t|
    t.integer  "product_model_id"
    t.integer  "category_attribute_id"
    t.string   "value"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "product_model_attributes", ["category_attribute_id"], :name => "index_product_model_attributes_on_category_attribute_id"
  add_index "product_model_attributes", ["product_model_id"], :name => "index_product_model_attributes_on_product_model_id"

  create_table "product_models", :force => true do |t|
    t.string   "title"
    t.string   "comment"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.integer  "category_id"
  end

  add_index "product_models", ["category_id"], :name => "index_product_models_on_category_id"

  create_table "products", :force => true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.integer  "category_id"
    t.decimal  "honey_price"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "using_condition"
    t.integer  "product_model_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
  end

  add_index "products", ["category_id"], :name => "index_products_on_category_id"
  add_index "products", ["product_model_id"], :name => "index_products_on_product_model_id"

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "profile_name"
    t.string   "email",                                   :default => "", :null => false
    t.string   "encrypted_password",                      :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                           :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.string   "card_type"
    t.string   "card_name"
    t.string   "card_expired_month",         :limit => 2
    t.string   "card_expired_year",          :limit => 4
    t.string   "card_postal_code"
    t.string   "address"
    t.string   "stripe_customer_id"
    t.string   "stripe_card_token"
    t.string   "card_last_four_number"
    t.string   "stripe_coupon"
    t.string   "stripe_customer_card_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
