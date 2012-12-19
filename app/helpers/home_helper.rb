module HomeHelper
  
  def filter_using_conditions
    html = %Q{<h3 class="s_category">Using conditions</h3>}
    Product::USING_CONDITIONS.keys.each do |condition|
      html += %Q{
                  <input type="checkbox" attr-filter-option='#{condition.to_s}'>#{Product::USING_CONDITIONS[condition]}</input>
                }
    end
    raw html
  end

end
