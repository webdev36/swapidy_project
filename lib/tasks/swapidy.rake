namespace :swapidy do

  namespace :db do
    
    desc "Insert some macbook and ipod. Make fewless products only to be for selling"
    task :add_macbooks => :environment do
      logger = Logger.new("log/swapidy_tasks.log")
      
      Product.where("using_condition != ?", Product::USING_CONDITIONS[:flawless]).each do |product|
        product.update_attribute(:for_buy, false)
      end
      
      file = File.open(File.join(Rails.root, 'demo_data', "products_20130103.csv"),"r")
      content = file.read
      content.split(/\r/).each do |line|
        logger.info "line: #{line}"
        product = Product.import_from_textline(line) #rescue nil
        logger.info product
      end

    end
    
    desc "Rest database from excel file"
    task :reset => :environment do
      logger = Logger.new("log/swapidy_tasks.log")
      
      file = File.open(File.join(Rails.root, 'demo_data', "products_init.csv"),"r")
      content = file.read
      content.split(/\r/).each do |line|
        logger.info "line: #{line}"
        product = Product.import_from_textline(line) #rescue nil
        logger.info product
      end
    end

  end

end

