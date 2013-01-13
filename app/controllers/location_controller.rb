class LocationController < ApplicationController
  
  SUPPORTS = ["Bay Area"]
  OPTIONS = ["Bay Area", "LA", "Chicago", "Miami", "New York"]
  
  def change
    @location = params["location"] && !params["location"].blank? ? params["location"] : SUPPORTS.first
    if SUPPORTS.include? @location
      redirect_to "/"
    else
      render "/home/under_contruction"
    end
  end
  
end
