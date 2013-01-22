module LocationHelper

  def location_options
    html = LocationVote::OPTIONS.map{|option| "&quot;#{option}&quot;"}.join(",")
    raw "[#{html}]"
  end
  
  def current_location
    if params[:location] && !params[:location].blank? 
      params[:location]
    else
      LocationVote::SUPPORTS.first
    end
  end

end
