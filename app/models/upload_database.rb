class UploadDatabase < ActiveRecord::Base
  attr_accessible :data_content, :product_type
  belongs_to :user
  has_many :products
  after_create :import_products
  
  def import_products
    #data_content
    logger = Logger.new("log/upload_database.log") unless logger
    
    content = self.data_content
    product_type = self.product_type
    
    if product_type.to_s == "for_buying"
      product_type = 2
    elsif product_type.to_s == "for_selling"
      product_type = 1
    elsif product_type.to_s == "for_sell_only"
      product_type = 3
    end

    lines = content.split(/\r/)
    logger.info"Step2 #{lines}" 
    logger.info"Step2 #{product_type}"
    headers = lines[0].split(/\,/)
    logger.info "Step2 #{lines}"
    return nil if headers.size < 7
      
    ["Weight lb", "Memory Space", "Network Type", "Ram", "Hard Drive", "Processor (GHZ)", "General"].each do |cat_title|
      attrs = CategoryAttribute.where(:title => cat_title).each {|attr| attr.destroy }
    end

    lines.each_with_index do |line, index|
      next if index == 0
     
      #product = ImportExcelProduct.import_from_textline(line, headers, file_name == "products_20130114_buy.csv", nil, logger) #rescue nil
      product = UpdateDatabase.import_from_textline(line, headers, product_type, :return_if_existed, logger) #rescue nil      
#      return product if product 
    end
  
    rescue Exception => e
    logger.info e.message    
  end
end
