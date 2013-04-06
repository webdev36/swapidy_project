module UpdateDatabase

  INDEXES = {:title => 0,
             :price => 1,
             :price_for_good => 2,
             :price_for_poor => 3,
             #:price_for_buy => 4,
             #:price_for_good_buy => 5,
             #:price_for_poor_buy => 6,
             :category => 4,
             :product_model => 5,
             :weight_lb => 6
            }
  PROPERTY_START_INDEX = 7
  
  def self.import_from_textline(textline, headers, product_type, action_type = :updated_if_existed, logger = nil)
    logger = Logger.new("log/swapidy_tasks.log") unless logger
    columns = textline.split(/,/).map{|value| value.strip}
    logger.info "columns.size: #{columns.size} - headers.size: #{headers.size}"
    return if columns.size < PROPERTY_START_INDEX || columns.size > headers.size
    logger.info "Product_type: #{product_type}"

    category = Category.find_by_title columns[INDEXES[:category]]
    category = Category.create(:title => columns[INDEXES[:category]]) unless category
    logger.info "category: #{category.id} - #{category.title}"

    model = category.product_models.find_by_title columns[INDEXES[:product_model]]
    model = category.product_models.create(:title => columns[INDEXES[:product_model]], :weight_lb => columns[INDEXES[:weight_lb]].to_i) unless model
    #logger.info "model: #{model.id} - #{model.title}"
    if product_type.to_i == 1
      logger.info "Product _swaptype #{product_type}"
      product = Product.where(:title => columns[INDEXES[:title]], :swap_type => 1).first
    elsif product_type.to_i == 2
     logger.info "Product _swaptype #{product_type}"
      product = Product.where(:title => columns[INDEXES[:title]], :swap_type => 2).first
    elsif product_type.to_i == 3
      logger.info "Product _swaptype #{product_type}"
      product = Product.where(:title => columns[INDEXES[:title]], :swap_type => 3).first  
    end
    
    logger.info "Product column #{columns[INDEXES[:title]]} --swap_type #{product_type}"
    
    if product.present?
      return product unless action_type   
      logger.info "Step1 #{product.title} --product_type #{product.swap_type}"
      if (product_type.to_i && product_type.to_i == 2)
        product.price_for_buy = (columns[INDEXES[:price]].to_f rescue nil)
        product.price_for_good_buy = (columns[INDEXES[:price_for_good]].to_f rescue nil)
        product.price_for_poor_buy = (columns[INDEXES[:price_for_poor]].to_f rescue nil)
      else
        product.price_for_sell = (columns[INDEXES[:price]].to_f rescue nil)
        product.price_for_good_sell = (columns[INDEXES[:price_for_good]].to_f rescue nil)
        product.price_for_poor_sell = (columns[INDEXES[:price_for_poor]].to_f rescue nil)
        logger.info "Product for sell  #{columns[INDEXES[:price]]} -- #{columns[INDEXES[:price_for_good]]}"
      end
    else
      logger.info "Step3"
      product = Product.new(:title => columns[INDEXES[:title]])

      if (product_type.to_i && product_type.to_i == 2)
        product.price_for_buy = (columns[INDEXES[:price]].to_f rescue nil)
        product.price_for_good_buy = (columns[INDEXES[:price_for_good]].to_f rescue nil)
        product.price_for_poor_buy = (columns[INDEXES[:price_for_poor]].to_f rescue nil)
      else
        product.price_for_sell = (columns[INDEXES[:price]].to_f rescue nil)
        product.price_for_good_sell = (columns[INDEXES[:price_for_good]].to_f rescue nil)
        product.price_for_poor_sell = (columns[INDEXES[:price_for_poor]].to_f rescue nil)
        logger.info "Product for sell  #{columns[INDEXES[:price]]} -- #{columns[INDEXES[:price_for_good]]}"
      end
      product.swap_type = product_type.to_i 
      product.category = category
      product.product_model = model
    end
    # if for_buying
      # logger.info "Step4"
      # product.price_for_buy = (columns[INDEXES[:price]].to_f rescue nil)
      # product.price_for_good_buy = (columns[INDEXES[:price_for_good]].to_f rescue nil)
      # product.price_for_poor_buy = (columns[INDEXES[:price_for_poor]].to_f rescue nil)
    # else
      # logger.info "Step4"
      # product.price_for_sell = (columns[INDEXES[:price]].to_f rescue nil)
      # product.price_for_good_sell = (columns[INDEXES[:price_for_good]].to_f rescue nil)
      # product.price_for_poor_sell = (columns[INDEXES[:price_for_poor]].to_f rescue nil)
    # end

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
    if product.save
      logger.info "Product_for save: #{product.title} === #{product.swap_type}"
      logger.info "Product_for save: #{product.price_for_buy} === #{columns[INDEXES[:price]].to_f}"
      return product 
    else
      logger.info product.errors.full_messages
      return nil
    end  
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
    
    model = category.product_models.find_by_title columns[MODEL_INDEXES[:product_model]]
    return model if model
    model = category.product_models.create(:title => columns[MODEL_INDEXES[:product_model]], 
                                           :weight_lb => columns[MODEL_INDEXES[:weight_lb]])
    
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
    image.photo = File.open(File.join(Rails.root, 'demo_data', 'images', columns.last))
    image.save
    
    return model if model.save
  end

end
