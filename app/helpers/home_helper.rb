module HomeHelper
  
  def filter_using_conditions
    html = %Q{<h3 class="s_category">Conditions</h3>}
    Product::USING_CONDITIONS.keys.each do |condition|
      html += %Q{
                  <input type="checkbox" class="regular_checkbox" attr-filter-option='#{condition.to_s}'>#{Product::USING_CONDITIONS[condition]}</input>
                }
    end
    raw html
  end
  
  def product_using_condition_names 
    Product::USING_CONDITIONS.keys.map{|key| key.to_s}.join(" ")
  end

end
