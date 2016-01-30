module NumberFormatting
  def money(value)
    v = value.to_f.round(2)
    v = v.to_i if v.to_i == v
    v = v.to_s.reverse.gsub(/(\d{3})/,"\\1,").chomp(",").reverse
    "&pound;#{v}".html_safe
  end

  def percentage(value)
    return "0%" if value.blank? || value == 0
    value = value.to_f if value.respond_to?(:to_f)
    value = value.round(0).to_i
    "#{value}%"
  end
end
