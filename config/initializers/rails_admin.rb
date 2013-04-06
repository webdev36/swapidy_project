# RailsAdmin config file. Generated on December 26, 2012 10:58
# See github.com/sferik/rails_admin for more informations
require Rails.root.join('lib', 'rails_admin_resend.rb')
require Rails.root.join('lib', 'rails_admin_reminder_order.rb')
require Rails.root.join('lib', 'rails_admin_decline_order.rb')
require Rails.root.join('lib', 'rails_admin_complete_order.rb')
require Rails.root.join('lib', 'rails_admin_cancel_order.rb')
require Rails.root.join('lib', 'rails_admin_delivery_order.rb')
  
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
  #config.excluded_models = [Comment, Post]

  # Add models here if you want to go 'whitelist mode':
  config.included_models = [BrandEmail, BrandEmailCustomer, Category, CategoryAttribute, Image, Order, OrderProduct, ShippingStamp, PaymentTransaction, Product, ProductModel, ProductAttribute, ProductModelAttribute, User, FreeHoney, RedeemCode, SwapidySetting, LocationVote,UploadDatabase ]

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
  module RailsAdmin
    module Config
      module Actions
        class Reminder < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
        class Complete < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
        class Cancel < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
        class Decline < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
        class Resend < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
         class Delivery < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end
  
  config.actions do
    # root actions
    dashboard                     # mandatory
    # collection actions 
    index                         # mandatory
    new
    export
    history_index
    bulk_delete
    # member actions
    show
    edit
    delete
    history_show
    show_in_app
    
    # Set the custom action here
    resend do
      # Make it visible only for comments model. You can remove this if you don't need.
      visible do
        bindings[:abstract_model].model.to_s == "ShippingStamp"
      end
    end
     delivery do
     visible do
       bindings[:abstract_model].model.to_s == "Order"
      end
    end
    reminder do
      visible do
        bindings[:abstract_model].model.to_s == "Order"
      end
    end
    complete do
      visible do
        bindings[:abstract_model].model.to_s == "Order"
      end
    end
    decline do
      visible do
        bindings[:abstract_model].model.to_s == "Order"
      end
    end
    cancel do
      visible do
        bindings[:abstract_model].model.to_s == "Order"
      end
    end
  end

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
      field :title
      field :user
      field :product_models
      field :sort_number
     end
     export do; end
     show do; end
     edit do
      field :title
      field :sort_number
     end
     create do; end
     update do; end
  end

  config.model CategoryAttribute do
      object_label_method do
        :to_s
      end
       configure :category, :belongs_to_association 
       configure :attribute_type, :string 
       configure :title, :string 
       configure :created_at, :datetime 
       configure :updated_at, :datetime   #   # Sections:
     list do
      filters [:title, :attribute_type, :category]
      field :title
      field :attribute_type
      field :category
     end
     export do; end
     show do; end
     edit do
      field :title
      field :attribute_type
      field :category
     end
     create do; end
     update do; end
  end
  config.model Image do
       configure :for_object, :polymorphic_association   #   # Found columns:
       configure :sum_attribute_names, :string 
       configure :photo, :paperclip 
       configure :title, :string 
       configure :is_main, :boolean 
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
  
  config.model ProductAttribute do
  #    # Found associations:
    configure :product, :belongs_to_association 
    configure :product_model_attribute, :belongs_to_association   #   # Found columns:
    configure :product_id, :integer         # Hidden 
    configure :product_model_attribute_id, :integer         # Hidden 
    list do
      filters [:product]
      field :product
      field :product_model_attribute
    end
    export do; end
    show do
      field :product
      field :product_model_attribute
    end
    edit do
      field :product
      field :product_model_attribute
    end
    create do; end
    update do; end
  end
  config.model ProductModel do
    configure :category, :belongs_to_association 
    configure :product_model_attributes, :has_many_association 
    configure :images, :has_many_association   #   # Found columns:
    configure :created_at, :datetime 
    configure :updated_at, :datetime 

    list do
      filters [:title, :category]
      field :title
      field :sort_number
      field :category
      field :images
      field :weight_lb
      field :comment
    end
    export do; end
    show do; end
    update do
      field :title
      field :sort_number
      field :product_model_attributes
      field :images
      field :comment
      field :weight_lb
    end
    create do
      field :title
      field :sort_number
      field :category
      field :product_model_attributes
      field :images
      field :comment
      field :weight_lb
    end
    edit do; end
  end
  config.model ProductModelAttribute do
    configure :product_model, :belongs_to_association 
    configure :category_attribute, :belongs_to_association   #   # Found columns:
    configure :value, :string 
    list do
      filters [:product_model, :category_attribute]
      field :product_model do 
        searchable [:title, :id]
      end
      field :category_attribute do
        searchable [:title, :id]
      end
      field :value
    end
     
    create do; end
    update do; end
  end
  config.model User do
    object_label_method :email
    configure :first_name, :string 
    configure :last_name, :string 
    configure :full_name, :string
    configure :email, :string 
    configure :password, :password         # Hidden 
    configure :password_confirmation, :password         # Hidden 
    configure :sign_in_count, :integer 
    configure :last_sign_in_at, :datetime 
    configure :created_at, :datetime 
    configure :updated_at, :datetime 
    configure :card_type, :string 
    configure :card_name, :string 
    configure :card_expired_month, :string 
    configure :card_expired_year, :string 
    configure :card_expired_date, :date 
    configure :address, :string 
    configure :stripe_customer_id, :string 
    configure :card_last_four_number, :string 
    configure :balance_amount, :decimal 
    configure :is_admin, :boolean
    list do
      field :full_name
      field :email
      field :is_admin
      field :balance_amount
      field :last_sign_in_at
    end
    export do; end
    show do
      field :first_name
      field :last_name
      field :email
      field :is_admin
      field :balance_amount
      field :address
      field :card_type
      field :card_name
      field :card_expired_date
      field :card_last_four_number
      field :stripe_customer_id
      field :last_sign_in_at
    end
    update do
      field :full_name
      field :email
      field :is_admin
      field :balance_amount
      field :address
    end
    create do; end
    edit do; end
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
  
  config.model ShippingStamp do
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
     list do; end
  #   export do; end
     show do; end
  #   reprint do; end
  #   edit do; end
  #   create do; end
  #   update do; end
  
  end
  
  config.model SwapidySetting do
    configure :value_type, :enum do
      enum do
        SwapidySetting::TYPES.keys.map {|key| [SwapidySetting::TYPES[key], SwapidySetting::TYPES[key]]}
      end
    end
    list do
      field :title
      field :value
      field :value_type
    end
    export do
      field :title
      field :value
      field :value_type
      field :created_at
      field :updated_at
    end
    show do
      field :title
      field :value
      field :value_type
      field :created_at
      field :updated_at
    end
    edit do
      field :title
      field :value_type
      field :value
    end
  end

  config.model RedeemCode do
    #configure :expired?, :boolean
    configure :status, :enum do
      enum do
        RedeemCode::STATUES.keys.map {|key| [key, RedeemCode::STATUES[key]]}
      end
    end
    
    list do
      filters [:status]

      field :status
      field :code
      field :amount
      field :expired_date
      field :users
      field :created_at
      field :updated_at
    end
    export do
      field :status
      field :code
      field :amount
      field :expired_date
      field :users
      field :created_at
      field :updated_at
    end
    show do
      field :status
      field :code
      field :amount
      field :expired_date
      field :users
      field :created_at
      field :updated_at
    end
    create do
      field :code
      field :amount
      #field :expired_date
    end
    update do
      field :status
      field :amount
      #field :expired_date
    end
  end

  config.model FreeHoney do
    #configure :expired?, :boolean
    configure :status, :enum do
      enum do
        FreeHoney::STATUES.keys.map {|key| [key, FreeHoney::STATUES[key]]}
      end
    end
    
    list do
      field :status
      field :receiver_title
      field :sender_title
      field :receiver_amount
      #field :expired?
      field :expired_date
      field :completed_at
      field :sender_amount
      field :created_at
    end
    export do
      field :status
      field :receiver_title
      field :sender_title
      field :receiver_amount
      field :expired_date
      field :completed_at
      field :sender_amount
      field :created_at
    end
    show do
      field :status
      field :receiver_title
      field :sender_title
      field :receiver_amount
      field :sender_amount
      field :token_key
      field :created_at
      field :expired?
      field :expired_date
      field :completed_at
    end
    create do
      field :receiver_email
      field :receiver
      field :receiver_amount
      field :sender_amount
      #field :expired_date
    end
    update do
      field :status
      field :expired_date
    end
  end
  
  config.model Product do
    
    configure :swap_type, :enum do
      enum do
        Product::SWAP_TYPES.keys.map {|key| [Product::SWAP_TYPES[key], key]}
      end
    end
    list do
      filters [:swap_type, :title, :product_model]
      field :title
      field :swap_type
      field :sell_prices
      field :buy_prices
      field :category
      field :product_model
      field :images
    end
    export do
      field :title
      field :swap_type
      field :price_for_sell
      field :price_for_good_sell
      field :price_for_poor_sell
      field :price_for_buy
      field :price_for_good_buy
      field :price_for_poor_buy
      field :category
      field :product_model
      field :images
      field :product_model_attributes
    end
    show do
      field :category
      field :product_model
      field :title
      field :swap_type
      field :price_for_sell
      field :price_for_good_sell
      field :price_for_poor_sell
      field :price_for_buy
      field :price_for_good_buy
      field :price_for_poor_buy
      field :images
      field :product_attributes
    end
    edit do; end
    create do
      field :product_model
      field :title
      field :price_for_sell
      field :price_for_good_sell
      field :price_for_poor_sell
      field :price_for_buy
      field :price_for_good_buy
      field :price_for_poor_buy
    end
    update do
      field :title
      field :price_for_sell
      field :price_for_good_sell
      field :price_for_poor_sell
      field :price_for_buy
      field :price_for_good_buy
      field :price_for_poor_buy
      field :images
      field :product_attributes
    end
  end

  config.model OrderProduct do
    configure :using_condition, :enum do
      enum do
        Product::USING_CONDITIONS.keys.map {|key| [Product::USING_CONDITIONS[key], Product::USING_CONDITIONS[key]]}
      end
    end
    configure :sell_or_buy do
      read_only true
    end
    list do
      field :sell_or_buy
      field :using_condition
      field :price
      field :product
    end
    export do
      field :sell_or_buy
      field :product_title
      field :weight_lb
      field :using_condition
      field :price
      field :order
    end
    show do
      field :sell_or_buy
      field :product
      field :weight_lb
      field :using_condition
      field :price
      field :order
    end
    edit do
      field :sell_or_buy
      field :status do
        read_only true
      end
      field :product
      field :product_title
      field :weight_lb
      field :using_condition
      field :price
      
      field :order
    end
  end  
  config.model Order do
    
    configure :status, :enum do
      pretty_value do
        util = bindings[:object]
        util.status_title
      end
      enum do
        [['Pending, waiting for arrival', Order::STATUES[:pending]], 
         ['Reminder', Order::STATUES[:reminder]], 
         ['Cancelled', Order::STATUES[:cancelled]], 
         ['Confirmed to ship', Order::STATUES[:confirmed_to_ship]], 
         ['Declined', Order::STATUES[:declined]],
         ['Completed', Order::STATUES[:completed]],
         ['Delivery', Order::STATUES[:delivery]]]
      end
    end
    
    list do
      filters [:status, :user, :shipping_address, :shipping_city]
      field :status
      field :balance_amount
      field :user
      field :shipping_fullname
      field :shipping_address
      field :shipping_city
      field :shipping_state
      field :shipping_zip_code
    end
    export do
      field :status
      field :balance_amount
      field :user
      field :shipping_fullname
      field :shipping_address
      field :shipping_city
      field :shipping_state
      field :shipping_zip_code
    end
    show do
      field :status
      field :balance_amount
      field :user
      field :shipping_fullname
      field :shipping_address
      field :shipping_city
      field :shipping_state
      field :shipping_zip_code
    end
    edit do
      field :status do
        read_only true
      end
      
      field :user
      field :shipping_first_name
      field :shipping_last_name
      field :shipping_address
      field :shipping_city
      field :shipping_state, :enum do
        enum do 
          Carmen::Country.named('United States').subregions.collect { |sr| [sr.name, sr.code] }
        end
      end
      field :shipping_zip_code
    end
  #   create do; end
  #   update do; end
  end
  
  config.model LocationVote do
    configure :using_condition, :enum do
      enum do
        LocationVote::OPTIONS.map {|location| [location, location] }
      end
    end
    
    list do
       filters [:location, :user]
       field :location
       field :user_ip
       field :user
       field :created_at
     end
     export do
       field :location
       field :user_ip
       field :user
       field :created_at
     end
  end
  
  config.model BrandEmail do
    list do
      filters [:title]
      field :title
      field :email_total
      field :sending_count
      field :sent_count
      field :failure_count
      field :created_at
    end
    export do
      field :title
      field :email_total
      field :sending_count
      field :sent_count
      field :failure_count
      field :created_at
      field :customers
    end
    show do
      field :title
      field :content
      field :email_total
      field :sending_count
      field :sent_count
      field :failure_count
      field :created_at
      field :customers
    end
    create do
      field :title
      field :content, :text do
        help "Required. Length up to 2000."
      end
      field :customers, :text
      field :suggest_user_emails, :text do
        read_only true
      end
    end
  end
  
  config.model BrandEmailCustomer do
    configure :status, :enum do
      enum do
        [['Sending', BrandEmailCustomer::STATUS[:sending]], 
         ['Sent', BrandEmailCustomer::STATUS[:sent]], 
         ['Failure', BrandEmailCustomer::STATUS[:failure]]]
      end
    end
    list do
      filters [:brand_email, :email]
      field :email
      field :brand_email
      field :user
      field :status
      field :created_at
      field :updated_at
    end
    export do
      field :email
      field :brand_email
      field :user
      field :status
      field :created_at
      field :updated_at
    end
  end
  
  config.model UploadDatabase do
    configure :data_content,:text 
    configure :product_type
    #configure :product_id, :integer         # Hidden 
    list do
      field :data_content
      field :product_type  
    end
    export do
      field :data_content
      field :product_type
    end
    show do
      field :data_content
      field :product_type
    end
    create do
      field :product_type,:enum do
        label "ProductType"
        enum do
          ['for_buying','for_selling','for_sell_only']
        end
      end
      field :data_content      
    end
  end

end