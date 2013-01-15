class LocationController < ApplicationController
  
  SUPPORTS = ["Bay Area"]
  OPTIONS = ["Bay Area", "LA", "San Diego", "Chicago", "Austin", "New York", "Boston"]
  
  def change
    @location = params["location"] && !params["location"].blank? ? params["location"] : SUPPORTS.first
    if SUPPORTS.include? @location
      redirect_to "/"
    else
      render "/home/under_contruction"
    end
  end
  
end
