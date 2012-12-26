class HomeController < ApplicationController

  layout 'application_with_slider', :only => [:index]

  before_filter :require_login, :only => [:settings]
  
  def index
  end
  
  def settings
    
  end
  
  def static_page
    render params[:content]
  end

end
