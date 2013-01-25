class ProductsController < ApplicationController

  def show
    @product = Product.find params[:id]
    params[:using_condition]
  end
end
