
module CardInfo
  
  CARD_ATTRS = [:type, :name, :last_four_number, :number, :cvc, :expired_month, :expired_year, :strip_card_token]
  
  def self.included(base)
    #attr_accessible :card_type, :card_name, :card_expired_month, :card_expired_year, :card_last_four_number  
  end
  
  def has_card_info?
    return false if (card_type || "").blank? && (card_last_four_number || "").blank? && 
        (card_expired_month || "").blank? && (card_expired_year || "").blank? && (card_type || "").blank?
    return true
  end
  
  def card_info_in_hash
    return {:card_type => self.card_type,
            :card_name => self.card_name,
            :card_expired_month => self.card_expired_month,
            :card_expired_year => self.card_expired_year, 
            :card_last_four_number => self.card_last_four_number,
            :card_expired_date => self.card_expired_date}
  end
  
  def card_expired_date
    return "#{self.card_expired_year}-#{self.card_expired_month}-01".to_date rescue nil
  end
  def card_expired_date=(date)
    self.card_expired_month = date.month.to_s
    self.card_expired_year = date.year.to_s
  end
  
  def new_card_info
    if self.new_stripe_card_token && !self.new_stripe_card_token.blank? && 
        (self.stripe_card_token.nil? || self.new_stripe_card_token != self.stripe_card_token)
      {:card_name => self.new_card_name,
       :card_type => self.new_card_type,
       :card_expired_year => self.new_card_expired_year,
       :card_expired_month => self.new_card_expired_month,
       :card_last_four_number => self.new_card_last_four_number,
       :card_expired_date => ("#{self.new_card_expired_year}-#{self.new_card_expired_month}-01".to_date rescue nil)}
    else
      nil
    end
  end
  
  def copy_to_new_card
    self.new_card_expired_year = self.card_expired_year
    self.new_card_expired_month = self.card_expired_month
    self.new_card_name = self.card_name
    unless (self.card_last_four_number || "").blank?
      self.new_card_cvc = "xxx"
      self.new_card_number = "xxxx-xxxx-xxxx-#{self.card_last_four_number}" 
    end
  end

end