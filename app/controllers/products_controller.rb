class ProductsController < ApplicationController
  def show
    @product = Product.find params[:id]
    params[:using_condition]
  end
  def csv_import
  	if user_signed_in?
#  		render :text => "You are not an administrator" and return if !current_user.is_admin?
  		file_name = params[:fn].to_s+".csv"  		
	  	product_models = ProductModel.all.map{|pm| [pm.id, pm.title]}
	  	pma_attr = ["Weight lb", "Year", "Space",	"Network", "Color", "Generation", "Screen Size",	"Retina Display",	"Memory",	"Hard Disk", "Processor"]
	 	
	  	categories = Category.all.map{|cat| [cat.id, cat.title]}
	  	headers = [ "val",					"Flawlesss",			"Good",		"Poor",				"Category",		"Product model",	
						       "Weight lb",		"Year",						"Space",	"Network",		"Color",			"Generation",
						       "Screen Size",	"Retina Display",	"Memory",	"Hard Disk",	"Processor" ]

			CSV.foreach(file_name) do |row|
				c_id = categories.find{|ct| ct[1]==row[4]}
				if c_id.present?
			    product = Product.new()
			    product.title = row[0]
			    product.category_id = c_id[0]
			    product.product_model_id = product_models.find{|pm| pm[1]==row[5]}[0]
			    product.user_id = nil
			    product.price_for_sell = row[1]
			    product.price_for_good_sell = row[2]
			    product.price_for_poor_sell = row[3]
			    product.price_for_buy = nil
					product.price_for_good_buy = nil 
					product.price_for_poor_buy = nil
			    product.swap_type = 3
#			    product.upload_database_id = nil	
			    if product.save 	    			    	
				    CategoryAttribute.all.each do |ca| 
				    	if pma_attr.include? ca.title
				    		pma = ProductModelAttribute.new
				    		pma.product_model_id = product_models.find{|pm| pm[1]==row[5]}[0]
				    		pma.category_attribute_id =ca.id
				    		pma.value = row[headers.index(ca.title)]
				    		if pma.save	
									pa = ProductAttribute.new
					    		pa.product_id = product.id
					    		pa.product_model_attribute_id = pma.id
					    		pa.value = nil
					    		pa.save
								end
				    	end
				    end #ca
				  end #product save

				end						
		 	end #foreach 
		 	redirect_to "/"
  	else
  		render :text=> "please login with administrator"
  	end  	
  end 
end
