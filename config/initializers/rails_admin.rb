# RailsAdmin config file. Generated on December 26, 2012 10:58
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|

  # If your default_local is different from :en, uncomment the following 2 lines and set your default locale here:
  # require 'i18n'
  # I18n.default_locale = :de

  config.current_user_method { current_user } # auto-generated

  config.authorize_with do
    redirect_to main_app.root_path unless warden.user.is_admin?
  end

  # If you want to track changes on your models:
  # config.audit_with :history, User

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, User

  # Set the admin name here (optional second array element will appear in a beautiful RailsAdmin red ©)
  config.main_app_name = ['Swapidy', 'Admin']
  # or for a dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }


  #  ==> Global show view settings
  # Display empty fields in show views
  # config.compact_show_view = false

  #  ==> Global list view settings
  # Number of default rows per-page:
  # config.default_items_per_page = 20

  #  ==> Included models
  # Add all excluded models here:
  # config.excluded_models = [Category, CategoryAttribute, Comment, Image, Order, PaymentTransaction, Post, Product, ProductAttribute, ProductModel, ProductModelAttribute, User, UserProvider]

  # Add models here if you want to go 'whitelist mode':
  config.included_models = [Category, CategoryAttribute, Image, Order, PaymentTransaction, Product, ProductModel, ProductModelAttribute, User]

  # Application wide tried label methods for models' instances
  # config.label_methods << :description # Default is [:name, :title]

  #  ==> Global models configuration
  # config.models do
  #   # Configuration here will affect all included models in all scopes, handle with care!
  #
  #   list do
  #     # Configuration here will affect all included models in list sections (same for show, export, edit, update, create)
  #
  #     fields_of_type :date do
  #       # Configuration here will affect all date fields, in the list section, for all included models. See README for a comprehensive type list.
  #     end
  #   end
  # end
  #
  #  ==> Model specific configuration
  # Keep in mind that *all* configuration blocks are optional.
  # RailsAdmin will try his best to provide the best defaults for each section, for each field.
  # Try to override as few things as possible, in the most generic way. Try to avoid setting labels for models and attributes, use ActiveRecord I18n API instead.
  # Less code is better code!
  # config.model MyModel do
  #   # Cross-section field configuration
  #   object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #   label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #   label_plural 'My models'      # Same, plural
  #   weight -1                     # Navigation priority. Bigger is higher.
  #   parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #   navigation_label              # Sets dropdown entry's name in navigation. Only for parents!
  #   # Section specific configuration:
  #   list do
  #     filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #     items_per_page 100    # Override default_items_per_page
  #     sort_by :id           # Sort column (default is primary key)
  #     sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     # Here goes the fields configuration for the list view
  #   end
  # end

  # Your model's configuration, to help you get started:

  # All fields marked as 'hidden' won't be shown anywhere in the rails_admin unless you mark them as visible. (visible(true))

  config.model Category do
     # Found associations:
       parent :user, :belongs_to_association 
     #  configure :products, :has_many_association 
       configure :product_models, :has_many_association 
       configure :category_attributes, :has_many_association 
       configure :images, :has_many_association   #   # Found columns:
     #  configure :id, :integer 
       configure :title, :string 
     #  configure :user_id, :integer         # Hidden 
       configure :created_at, :datetime 
       configure :updated_at, :datetime   #   # Sections:
     list do
      filters [:title]  
     end
     export do; end
     show do; end
     edit do; end
     create do; end
     update do; end
  end

  config.model CategoryAttribute do
  #   # Found associations:
       configure :category, :belongs_to_association 
  #     configure :product_model_attributes, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :category_id, :integer         # Hidden 
       configure :attribute_type, :string 
       configure :title, :string 
       configure :created_at, :datetime 
       configure :updated_at, :datetime   #   # Sections:
     list do
      filters [:title, :attribute_type, :category]  
     end
     export do; end
     show do; end
     edit do; end
     create do; end
     update do; end
  end
  # config.model Comment do
  #   # Found associations:
  #     configure :post, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :commenter, :string 
  #     configure :body, :text 
  #     configure :post_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  # config.model Image do
  #   # Found associations:
  #     configure :for_object, :polymorphic_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :for_object_id, :integer         # Hidden 
  #     configure :for_object_type, :string         # Hidden 
  #     configure :sum_attribute_names, :string 
  #     configure :photo_file_name, :string         # Hidden 
  #     configure :photo_content_type, :string         # Hidden 
  #     configure :photo_file_size, :integer         # Hidden 
  #     configure :photo, :paperclip 
  #     configure :title, :string 
  #     configure :is_main, :boolean 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  
  config.model Order do
     # Found associations:
       configure :product, :belongs_to_association 
       configure :user, :belongs_to_association   #   # Found columns:
       configure :id, :integer 
       configure :product_id, :integer         # Hidden 
       configure :order_type, :integer 
       configure :user_id, :integer         # Hidden 
       configure :status, :integer 
       configure :created_at, :datetime 
       configure :updated_at, :datetime 
       configure :shipping_method, :string 
       configure :shipping_first_name, :string 
       configure :shipping_last_name, :string 
       configure :shipping_address, :string 
       configure :shipping_optional_address, :string 
       configure :shipping_city, :string 
       configure :shipping_state, :string 
       configure :shipping_zip_code, :string 
       configure :shipping_country, :string 
       configure :honey_price, :decimal 
       configure :using_condition, :string   #   # Sections:
     list do; end
     export do; end
     show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  end
  config.model PaymentTransaction do
  #   # Found associations:
       configure :user, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :user_id, :integer         # Hidden 
       configure :gateway, :integer 
       configure :payment_charge_id, :string 
       configure :payment_invoice_id, :string 
       configure :payment_type, :string 
       configure :status, :string 
       configure :amount, :decimal 
       configure :honey_money, :decimal 
       configure :card_name, :string 
       configure :card_type, :string 
       configure :card_expired_month, :string 
       configure :card_expired_year, :string 
       configure :card_last_four_number, :string 
       configure :created_at, :datetime 
       configure :updated_at, :datetime   #   # Sections:
     list do; end
     export do; end
     show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  end
  # config.model Post do
  #   # Found associations:
  #     configure :user, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :title, :string 
  #     configure :content, :text 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :user_id, :integer         # Hidden   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  config.model Product do
  #   # Found associations:
       configure :user, :belongs_to_association 
       configure :category, :belongs_to_association 
       configure :product_model, :belongs_to_association 
  #     configure :product_attributes, :has_many_association 
       configure :product_model_attributes, :has_many_association 
       configure :images, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
       configure :title, :string 
  #     configure :user_id, :integer         # Hidden 
  #     configure :category_id, :integer         # Hidden 
       configure :honey_price, :decimal 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
       configure :using_condition, :string 
  #     configure :product_model_id, :integer         # Hidden   #   # Sections:
     list do; end
     export do; end
     show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  end
  # config.model ProductAttribute do
  #   # Found associations:
  #     configure :product, :belongs_to_association 
  #     configure :product_model_attribute, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :product_id, :integer         # Hidden 
  #     configure :product_model_attribute_id, :integer         # Hidden 
  #     configure :value, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  config.model ProductModel do
  #   # Found associations:
       configure :category, :belongs_to_association 
  #     configure :products, :has_many_association 
       configure :product_model_attributes, :has_many_association 
       configure :images, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :title, :string 
  #     configure :comment, :string 
       configure :created_at, :datetime 
       configure :updated_at, :datetime 
  #     configure :category_id, :integer         # Hidden   #   # Sections:
     list do; end
     export do; end
     show do; end
     edit do; end
     create do; end
     update do; end
  end
  # config.model ProductModelAttribute do
  #   # Found associations:
  #     configure :product_model, :belongs_to_association 
  #     configure :category_attribute, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :product_model_id, :integer         # Hidden 
  #     configure :category_attribute_id, :integer         # Hidden 
  #     configure :value, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
  config.model User do
  #   # Found associations:
  #     configure :orders, :has_many_association 
  #     configure :trade_ins, :has_many_association 
  #     configure :user_providers, :has_many_association   #   # Found columns:
  #     configure :id, :integer 
       configure :first_name, :string 
       configure :last_name, :string 
  #     configure :profile_name, :string 
       configure :email, :string 
       configure :password, :password         # Hidden 
       configure :password_confirmation, :password         # Hidden 
  #     configure :reset_password_token, :string         # Hidden 
  #     configure :reset_password_sent_at, :datetime 
  #     configure :remember_created_at, :datetime 
       configure :sign_in_count, :integer 
  #     configure :current_sign_in_at, :datetime 
  #     configure :last_sign_in_at, :datetime 
  #     configure :current_sign_in_ip, :string 
  #     configure :last_sign_in_ip, :string 
       configure :created_at, :datetime 
       configure :updated_at, :datetime 
  #     configure :card_type, :string 
  #     configure :card_name, :string 
  #     configure :card_expired_month, :string 
  #     configure :card_expired_year, :string 
  #     configure :card_postal_code, :string 
       configure :address, :string 
  #     configure :stripe_customer_id, :string 
  #     configure :stripe_card_token, :string 
  #     configure :card_last_four_number, :string 
  #     configure :stripe_coupon, :string 
  #     configure :stripe_customer_card_token, :string 
       configure :honey_balance, :decimal 
  #     configure :provider_image, :string   #   # Sections:
     list do; end
     export do; end
     show do; end
     edit do; end
     create do; end
     update do; end
  end
  # config.model UserProvider do
  #   # Found associations:
  #     configure :user, :belongs_to_association   #   # Found columns:
  #     configure :id, :integer 
  #     configure :provider, :string 
  #     configure :uid, :string 
  #     configure :access_token, :string 
  #     configure :token_expires_at, :datetime 
  #     configure :user_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime   #   # Sections:
  #   list do; end
  #   export do; end
  #   show do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  # end
end