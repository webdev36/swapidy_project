class HomeController < ApplicationController

  layout 'application_with_slider', :only => [:index]

  before_filter :require_login, :only => [:settings]
  
  def index
  end
  
  def transactions
    
  end
  
  def notificate_amount
    
  end
  
  def notification
    
  end
  
  def static_page
    render params[:content]
  end
  
  

end
