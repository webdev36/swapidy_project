module HomeHelper
  
  def cart_products_empty?
    return true unless session[:cart_products] 
    return false if session[:cart_products][:sell] && !session[:cart_products][:sell].empty?
    return false if session[:cart_products][:buy] && !session[:cart_products][:buy].empty?
    return true
  end
  
  def cart_products
    #Rails.logger.info session[:cart_products]
    
    session[:cart_products] = {:sell => [], :buy => [], :max_order_product_id => 0} if session[:cart_products].nil?
    {:sell => session[:cart_products][:sell].map {|obj_hash| 
                order_product = OrderProduct.new(obj_hash)
                order_product.product = Product.find order_product.product_id rescue nil
                order_product.product ? order_product : nil 
              }.compact,
     :buy => session[:cart_products][:buy].map {|obj_hash| 
                order_product = OrderProduct.new(obj_hash)
                order_product.product = Product.find order_product.product_id rescue nil
                order_product.product ? order_product : nil
             }.compact
    }
  end
  
  def cart_amount
    amount = 0
    cart_products[:buy].each {|order_product| amount += order_product.price }
    cart_products[:sell].each {|order_product| amount -= order_product.price }
    return amount
  end 
  
  def add_cart_product cart_params
    session[:cart_products] = {:sell => [], :buy => [], :max_order_product_id => 0} if session[:cart_products].nil?
    session[:cart_products][:max_order_product_id] = (session[:cart_products][:max_order_product_id] || 0) + 1
    if cart_params[:type] && cart_params[:type] == "sell"
      session[:cart_products][:sell] << {:product_id => cart_params[:product_id].to_i, :price => cart_params[:price].to_i, :using_condition => cart_params[:using_condition], :order_product_id => session[:cart_products][:max_order_product_id]}
    elsif cart_params[:type] && cart_params[:type] == "buy"
      session[:cart_products][:buy] << {:product_id => cart_params[:product_id].to_i, :price => cart_params[:price].to_i, :using_condition => cart_params[:using_condition], :order_product_id => session[:cart_products][:max_order_product_id]}
    end
    Rails.logger.info "session cart #{session[:cart_products].to_s}"
  end
  
  def clear_cart_products
    session[:cart_products] = nil
  end 

end
