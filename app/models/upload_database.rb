class UploadDatabase < ActiveRecord::Base
  attr_accessible :data_content, :product_type
  belongs_to :user
  has_many :products
  after_create :import_products
  
  def import_products
    #data_content
          contents = UploadDatabase.first
          content = contents.data_content
          product_type = contents.product_type
          lines = content.split(/\r/)
         Rails.logger.info "Step2 #{lines}"
          headers = lines[0].split(/\,/)
          return nil if headers.size < 7
          
          ["Weight lb", "Memory Space", "Network Type", "Ram", "Hard Drive", "Processor (GHZ)", "General"].each do |cat_title|
            attrs = CategoryAttribute.where(:title => cat_title).each {|attr| attr.destroy }
          end

          lines.each_with_index do |line, index|
            next if index == 0
           
            #product = ImportExcelProduct.import_from_textline(line, headers, file_name == "products_20130114_buy.csv", nil, logger) #rescue nil
            product = ImportExcelProduct.import_from_textline(line, headers, product_type == "sell", :return_if_existed, logger) #rescue nil
            Rails.logger.info "Test :#{product.to_s}"
          end
      
      rescue Exception => e
        logger.info e.message
      
    
  end
end
