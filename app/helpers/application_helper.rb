module ApplicationHelper
  
  def page_title
    @page_title && !@page_title.blank? ? @page_title : "Swapidy"
  end
  
  def display_guide?
    if session[:need_to_display_guide]
      session[:need_to_display_guide] = nil
      return true
    end 
    return false
  end
  
  def csrf_meta_tag
    if protect_against_forgery?
      out = %(<meta name="csrf-param" content="%s"/>\n)
      out << %(<meta name="csrf-token" content="%s"/>)
      raw out % [ Rack::Utils.escape_html(request_forgery_protection_token),
              Rack::Utils.escape_html(form_authenticity_token) ]
    end
  end

  def format_num amount, precision_number = 0
    return '0.00' if amount.nil? || amount == 0.0
    is_negative = (amount < 0.0)
    amount = amount * (-1) if amount < 0
    currency_str = number_to_currency(amount, :precision => precision_number)
    currency_str = currency_str[1, currency_str.length]
    return currency_str if currency_str.to_f == 0.00
    return is_negative ? "-#{currency_str}" : currency_str
  end
  
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
    [["United States", "US"]]
  end

  def shipping_method_options
    Order::SHIPPING_METHODS.keys.map{|key| [Order::SHIPPING_METHOD_NAMES[key], Order::SHIPPING_METHODS[key]] }
  end
  
end
