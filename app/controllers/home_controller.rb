class HomeController < ApplicationController

  layout 'application_with_slider'

  def index
  end
  
  def static_page
    render params[:content]
  end

end
