module ApplicationHelper

  def format_date(input)
    input.strftime("%m/%d/%Y")
  end

  def format_price(input)
    '$' + '%.2f' % input.round(2)
  end

  def format_percent(percent)
    "#{percent}% Discount"
  end

  def format_threshold(item_number)
    "Item threshold: #{item_number} items"
  end
end
