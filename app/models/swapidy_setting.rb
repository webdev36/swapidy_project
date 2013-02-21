class SwapidySetting < ActiveRecord::Base
  attr_accessible :title, :value, :value_type
  
  validates :title, :value, :value_type, :presence => true

  validates_uniqueness_of :title
  before_validation :upcase_title
  
  TYPES = {:string => "String", :integer => "Number", :boolean => "Boolean", :float => "Float" }

  def self.get title
    return nil unless title
    setting = SwapidySetting.find_by_title title.to_s.upcase
    return nil unless setting
    
    if setting.value_type == TYPES[:integer]
      return setting.value.to_i
    elsif setting.value_type == TYPES[:boolean]
      return setting.value.strip.upcase == "TRUE"
    elsif setting.value_type == TYPES[:float]
      return setting.value.to_f
    else
      return setting.value.to_s
    end  
  end
  
  def self.init_default_titles
    [["FREE_MONEY-DEFAULT_RECEIVER_MONEY", "50.0", "Float"],
     ["FREE_MONEY-DEFAULT_REWARD_MONEY", "100.0", "Float"],
     ["FREE_MONEY-DEFAULT_EXPIRED_DAYS", "7", "Number"],
     ["REDEEM-DEFAULT_MONEY", "50.0", "Float"],
     ["REDEEM-DEFAULT_EXPIRED_DAYS", "7", "Number"]  ].each do |setting|
        SwapidySetting.create(:title => setting[0], :value => setting[1], :value_type => setting[2])   
   end
  end

  private

    def upcase_title
      self.title = self.title.upcase if self.title  
    end
end
