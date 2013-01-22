class LocationVote < ActiveRecord::Base
  attr_accessible :user_ip, :user_id, :location, :created_at
  
  belongs_to :user
  
  OPTIONS = ["Bay Area", "LA", "San Diego", "Chicago", "Austin", "New York", "Boston"]
  SUPPORTS = ["Bay Area"]
  UNSUPPORTS = OPTIONS.reject{ |location| SUPPORTS.include?(location) }
  
  def self.vote_count location
    return 0 if location.nil? || location.blank?
    return 500 + where(:location => location).count
  end
  
  def self.able_to_vote? user_ip, user_id
    vote_of_today(user_ip, user_id).nil?
  end
  
  def self.vote_of_today user_ip, user_id
    return where("user_id = ? AND created_at > ?", user_id, 1.days.ago).order("created_at desc").limit(1).first if user_id
    return where("user_ip = ? AND created_at > ?", user_ip, 1.days.ago).order("created_at desc").limit(1).first
  end

end
