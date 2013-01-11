namespace :swapidy do

  namespace :db do

    desc "Reset database from excel file"
    task :reset_products => :environment do
      logger = Logger.new("log/swapidy_tasks.log")
      
      file = File.open(File.join(Rails.root, 'demo_data', "products_20130110.csv"),"r")
      content = file.read
      lines = content.split(/\r/)
      headers = lines[0].split(",")
      
      return if headers.size < 10
      Product.all.each { |product| product.destroy }
      ProductModelAttribute.all.each { |a| a.destroy }
      ["Memory Space", "Network Type", "Ram", "Hard Drive", "Processor (GHZ)", "General"].each do |cat_title|
        attrs = CategoryAttribute.where(:title => cat_title).each {|attr| attr.destroy }
      end

      lines.each_with_index do |line, index|
        next if index == 0
        logger.info "line: #{line}"
        product = ImportExcelProduct.import_from_textline(line, headers, logger) #rescue nil
        logger.info product
      end
    end
    
    desc "Enter the default address"
    task :set_company_address => :environment do
      settings = {"COMPANY_NAME" => "Swapidy", 
                  "COMPANY_ADDRESS" => "211 Hope St. PO Box 390603", 
                  "COMPANY_CITY" => "Mountain View", 
                  "COMPANY_STATE" => "CA", 
                  "COMPANY_ZIP_CODE" => "94041"}
      settings.keys.each do |key|
        setting = SwapidySetting.find_by_title key
        setting = SwapidySetting.new(:title => key, :value_type => SwapidySetting::TYPES[:string]) unless setting
        setting.value = settings[key]
        setting.save
      end
    end

  end

end

