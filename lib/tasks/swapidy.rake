namespace :swapidy do

  namespace :db do
    
    desc "Reset all database"
    task :reset => :environment do
      #Delete all records
      User.all.each {|obj| obj.destroy }
      UserProvider.all.each {|obj| obj.destroy }
      
      Category.all.each {|obj| obj.destroy }
      FreeHoney.all.each {|obj| obj.destroy }
      Image.all.each {|obj| obj.destroy }
      Notification.all.each {|obj| obj.destroy }
      Order.all.each {|obj| obj.destroy }
      PaymentTransaction.all.each {|obj| obj.destroy }
      Product.all.each {|obj| obj.destroy }
      RedeemCode.all.each {|obj| obj.destroy }
      ShippingStamp.all.each {|obj| obj.destroy }
      
      admin = User.find_by_email 'admin@admin.com' rescue nil
      admin = User.new(email: 'admin@admin.com', password: '123456', password_confirmation: '123456', is_admin: true) unless admin
      admin.save
      
      category_names = {"Galaxy" => "cat_galaxy.png", "iPad" => "cat_ipad.png", "iPhone" => "cat_iphone.png", "Macbook" => "cat_macbook.png", "iPod" => "cat_ipod.png"}
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
      
      #reset_models
      #reset_products
    end
    
    desc "Insert to ProductModel database from excel file"
    task :insert_models => :environment do
      logger = Logger.new("log/swapidy_tasks.log")
      file = File.open(File.join(Rails.root, 'demo_data', "models_20130111.csv"),"r")
      content = file.read
      lines = content.split(/\r/)
      headers = lines[0].split(",")
      
      return nil if headers.size < 3
      
      lines.each_with_index do |line, index|
        next if index == 0
        logger.info "line: #{line}"
        model = ImportExcelProduct.import_model(line, headers, logger) #rescue nil
        logger.info model
      end
    end
    
    task :remove_products => :environment do
      Product.all.each {|product| product.destroy }
      Order.all.each {|o| o.destroy }
      PaymentTransaction.all.each {|obj| obj.destroy }
      ShippingStamp.all.each {|obj| obj.destroy }
    end
    
    task :remove_compotype_products => :environment do
      Product.where(:swap_type => 0).each {|o| 
        o.price_for_buy = nil
        o.price_for_good_buy = nil
        o.price_for_poor_buy = nil
        o.save
      }
    end
    
    desc "Insert products database from excel file"
    task :insert_products => :environment do
      logger = Logger.new("log/swapidy_tasks.log")
      logger.info "file_name"
      begin
        product_ids = []
        ["products_20130114_buy.csv", "products_20130114_sell.csv"].each do |file_name|
        #["products_20130114_sell.csv"].each do |file_name|
          logger.info file_name
          
          file = File.open(File.join(Rails.root, 'demo_data', file_name),"r")
          content = file.read
          lines = content.split(/\r/)
          
          headers = lines[0].split(/\,/)
          return nil if headers.size < 7
          
          ["Weight lb", "Memory Space", "Network Type", "Ram", "Hard Drive", "Processor (GHZ)", "General"].each do |cat_title|
            attrs = CategoryAttribute.where(:title => cat_title).each {|attr| attr.destroy }
          end

          lines.each_with_index do |line, index|
            next if index == 0
            logger.info "line: #{line}"
            product = ImportExcelProduct.import_from_textline(line, headers, file_name == "products_20130114_buy.csv", :update_if_existed, logger) #rescue nil
            # product_ids << product.id if product
            logger.info product
          end
        end
        
        # logger.info product_ids.to_s
        # del_products = Product.where("id not in (#{product_ids.join(',')})")
        # logger.info del_products.map{|p| p.id }.to_s
        # del_products.each {|p| p.destroy }
      rescue Exception => e
        logger.info e.message
      end
    end
    
    
    desc "Insert new products database from excel file"
    task :insert_new_products => :environment do
      logger = Logger.new("log/swapidy_tasks.log")
      begin
        product_ids = []
        ["products_20130114_buy.csv", "products_20130114_sell.csv"].each do |file_name|
          logger.info file_name
          
          file = File.open(File.join(Rails.root, 'demo_data', file_name),"r")
          content = file.read
          lines = content.split(/\r/)
          
          headers = lines[0].split(/\,/)
          return nil if headers.size < 7
          
          ["Weight lb", "Memory Space", "Network Type", "Ram", "Hard Drive", "Processor (GHZ)", "General"].each do |cat_title|
            attrs = CategoryAttribute.where(:title => cat_title).each {|attr| attr.destroy }
          end
          lines.each_with_index do |line, index|
            next if index == 0
            logger.info "line: #{line}"
            #product = ImportExcelProduct.import_from_textline(line, headers, file_name == "products_20130114_buy.csv", nil, logger) #rescue nil
            product = ImportExcelProduct.import_from_textline(line, headers, file_name == "products_20130114_buy.csv", :return_if_existed, logger) #rescue nil
            logger.info product
          end
        end
      rescue Exception => e
        logger.info e.message
      end
    end

    desc "Enter the default address"
    task :set_company_address => :environment do
      settings = {"COMPANY_NAME" => "Swapidy", 
                  "COMPANY_ADDRESS" => "1259 El Camino Real. #232", 
                  "COMPANY_CITY" => "Menlo Park", 
                  "COMPANY_STATE" => "CA", 
                  "COMPANY_ZIP_CODE" => "94025"}
      settings.keys.each do |key|
        setting = SwapidySetting.find_by_title key
        setting = SwapidySetting.new(:title => key, :value_type => SwapidySetting::TYPES[:string]) unless setting
        setting.value = settings[key]
        setting.save
      end
    end

  end

end

