class LocationController < ApplicationController
  
  layout 'application_without_footer'
  
  def change
    @location = params["location"] && !params["location"].blank? ? params["location"] : SUPPORTS.first
    if LocationVote::SUPPORTS.include? @location
      redirect_to "/"
    else
      @last_vote = LocationVote.vote_of_today(request.remote_ip, current_user ? current_user.id : nil)
      render "/location/vote"
    end
  end
  
  def vote
    if LocationVote.able_to_vote?(request.remote_ip, current_user ? current_user.id : nil)
      @last_vote = LocationVote.create(:location => params[:location_name], :user_ip => request.remote_ip, :user_id => (current_user ? current_user.id : nil))
      @return_content = render_to_string(:partial => "/location/votes")
    end
    respond_to do |format|
      format.js {  }
    end
  end
  
end
