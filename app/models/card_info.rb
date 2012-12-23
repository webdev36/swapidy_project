
module CardInfo
  
  CARD_ATTRS = [:type, :name, :last_four_number, :number, :cvc, :expired_month, :expired_year, :strip_card_token]
  
  def self.included(base)
    #attr_accessible :card_type, :card_name, :card_expired_month, :card_expired_year, :card_last_four_number  
  end
  
  def card_info_in_hash
    return {:card_type => self.card_type,
            :card_name => self.card_name,
            :card_expired_month => self.card_expired_month,
            :card_expired_year => self.card_expired_year, 
            :card_last_four_number => self.card_last_four_number}
  end
  
  def card_expired_date
    return "#{self.card_expired_year}-#{self.card_expired_month}-01".to_date rescue nil
  end
  def card_expired_date=(date)
    self.card_expired_month = date.month.to_s
    self.card_expired_year = date.year.to_s
  end

end