module ApplicationHelper

  def month_options
    options = []
    ["January", "February", "March", "April", "May", "June", "July",
     "August", "September", "October", "November", "December"].each_with_index do |month_name, index|
      options << [month_name, index + 1]
    end
    return options
  end

  def year_options value_options = {}
    current_year = Time.now.year
    options = []
    if value_options[:show_past]
      (-10..10).to_a.each {|number| options << [current_year + number, current_year + number] }
    else
      (0..10).to_a.each {|number| options << [current_year + number, current_year + number] }
    end
    options
  end

  def us_subregions
    Carmen::Country.named('United States').subregions.collect { |sr| [sr.name, sr.code] }
  end
  
  def country_options
    [["USA", "United States"]]
  end

  def shipping_method_options
    Order::SHIPPING_METHODS.keys.map{|key| [Order::SHIPPING_METHOD_NAMES[key], Order::SHIPPING_METHODS[key]] }
  end

  
end
