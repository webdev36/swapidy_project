class LocationVote < ActiveRecord::Base
  attr_accessible :user_ip, :user_id, :location, :created_at
  
  def self.vote_count location
    return 0 if location.nil? || location.blank?
    return 500 + where(:location => location).count
  end
  
  def self.able_to_vote? user_ip, user_id
    ip_voted = where("user_ip = ? AND created_at > ?", user_ip, 1.days.ago).count > 0
    return false if ip_voted
    return true unless user_id
    return where("user_id = ? AND created_at > ?", user_id, 1.days.ago).count == 0
  end
  
  def self.vote_of_today user_ip, user_id
    ip_vote = where("user_ip = ? AND created_at > ?", user_ip, 1.days.ago).order("created_at desc").limit(1).first
    return ip_vote if ip_vote
    return where("user_id = ? AND created_at > ?", user_id, 1.days.ago).order("created_at desc").limit(1).first
  end

end
