module ImportExcelProduct

  INDEXES = {:title => 0,
             :honey_price => 1,
             :price_for_good_type => 2,
             :price_for_poor_type => 3,
             :for_sell => 4,
             :for_buy => 5,
             :category => 6,
             :product_model => 7,
             :weight_lb => 8
            }
  PROPERTY_START_INDEX = 9
  
  def self.import_from_textline(textline, headers, logger = nil)
    
    logger = Logger.new("log/swapidy_tasks.log") unless logger
    
    columns = textline.split(/,/).map{|value| value.strip}
    logger.info "columns.size: #{columns.size} - headers.size: #{headers.size}"
    return if columns.size < PROPERTY_START_INDEX || columns.size > headers.size
    
    category = Category.find_by_title columns[INDEXES[:category]]
    category = Category.create(:title => columns[INDEXES[:category]]) unless category
    logger.info "category: #{category.id} - #{category.title}"

    model = category.product_models.find_by_title columns[INDEXES[:product_model]]
    model = category.product_models.create(:title => columns[INDEXES[:product_model]], :weight_lb => columns[INDEXES[:weight_lb]].to_i) unless model
    logger.info "model: #{model.id} - #{model.title}"
    
    product = Product.new(:title => columns[INDEXES[:title]], 
                          :honey_price => (columns[INDEXES[:honey_price]].to_f rescue nil),
                          :price_for_good_type => (columns[INDEXES[:price_for_good_type]].to_f rescue nil),
                          :price_for_poor_type => (columns[INDEXES[:price_for_poor_type]].to_f rescue nil),
                          :for_sell => (columns[INDEXES[:for_sell]] == "TRUE"),
                          :for_buy => (columns[INDEXES[:for_buy]] == "TRUE"))
    product.category = category
    product.product_model = model
    
    (PROPERTY_START_INDEX..(columns.size-1)).to_a.each do |column_index|
      next if columns[column_index].blank?
      logger.info "#{column_index}: #{headers[column_index]} - #{columns[column_index]}"
      
      cat_attr = category.category_attributes.find_by_title headers[column_index]
      cat_attr = category.category_attributes.create(:title => headers[column_index]) unless cat_attr
      
      model_attr_value = model.product_model_attributes.where(:category_attribute_id => cat_attr.id, :value => columns[column_index]).first
      unless model_attr_value
        model_attr_value = model.product_model_attributes.create(:value => columns[column_index])
        model_attr_value.category_attribute = cat_attr
        model_attr_value.save
      end
      
      attr = product.product_attributes.new
      attr.product_model_attribute = model_attr_value
    end
    return product if product.save
  end
  
  MODEL_INDEXES = {:category => 0,
             :product_model => 1,
             :weight_lb => 2
            }
  MODEL_PROPERTY_START_INDEX = 3
  def self.import_model(textline, headers, logger = nil)
    
    logger = Logger.new("log/swapidy_tasks.log") unless logger
    
    columns = textline.split(/,/).map{|value| value.strip}
    return if columns.size < MODEL_PROPERTY_START_INDEX || columns.size > headers.size
    
    category = Category.find_by_title columns[MODEL_INDEXES[:category]]
    category = Category.create(:title => columns[MODEL_INDEXES[:category]]) unless category
    
    model = category.product_models.find_by_title columns[INDEXES[:product_model]]
    model = category.product_models.create(:title => columns[MODEL_INDEXES[:product_model]], 
                                           :weight_lb => columns[MODEL_INDEXES[:weight_lb]]) unless model
    
    attr_names = []
    (MODEL_PROPERTY_START_INDEX..(columns.size-2)).to_a.each do |column_index|
      next if columns[column_index].blank?
      
      cat_attr = category.category_attributes.find_by_title headers[column_index]
      unless cat_attr
        cat_attr = category.category_attributes.create(:title => headers[column_index])
      end
      
      model_attr_value = model.product_model_attributes.where(:category_attribute_id => cat_attr.id, :value => columns[column_index]).first
      unless model_attr_value
        model_attr_value = model.product_model_attributes.new(:value => columns[column_index])
        model_attr_value.category_attribute = cat_attr
        model_attr_value.save
      end
      attr_names << model_attr_value.value
    end
    
    image = model.images.new(:sum_attribute_names => attr_names.join(" "), :is_main => true)
    image.photo = File.open("#{Rails.root}/demo_data/images/#{columns.last}")
    image.save
    
    return model if model.save
  end

end