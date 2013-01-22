class LocationController < ApplicationController
  
  layout 'application_without_footer'
  
  SUPPORTS = ["Bay Area"]
  OPTIONS = ["Bay Area", "LA", "San Diego", "Chicago", "Austin", "New York", "Boston"]
  
  
  def change
    @location = params["location"] && !params["location"].blank? ? params["location"] : SUPPORTS.first
    if SUPPORTS.include? @location
      redirect_to "/"
    else
      @last_vote = LocationVote.vote_of_today(request.remote_ip, current_user ? current_user.id : nil)
      render "/location/vote"
    end
  end
  
  def vote
    if LocationVote.able_to_vote?(request.remote_ip, current_user ? current_user.id : nil)
      @last_vote = LocationVote.create(:location => @vote_location, :user_ip => request.remote_ip, :user_id => (current_user ? current_user.id : nil))
      respond_to do |format|
        format.js { @return_content = render_to_string(:partial => "/location/vote") }
      end
    else
      redirect_to "/"
    end
  end
  
end
