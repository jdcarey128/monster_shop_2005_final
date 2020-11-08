class Cart
  attr_reader :contents

  def initialize(contents)
    @contents = contents
  end

  def add_item(item)
    @contents[item] = 0 if !@contents[item]
    @contents[item] += 1
  end

  def remove_one(item)
    @contents[item] -= 1
    if @contents[item] == 0
      @contents.delete(item)
    end
  end

  def total_items
    @contents.values.sum
  end

  def items
    item_quantity = {}
    @contents.each do |item_id,quantity|
      item_quantity[Item.find(item_id)] = quantity
    end
    item_quantity
  end

  def total_unique_item(item)
    @contents[item.id.to_s]
  end

  def subtotal(item)
    total = item.price * total_unique_item(item)
    return discount_subtotal(item, total) if apply_discount?(item)
    return total
  end

  def apply_discount?(item)
    if item.merchant.discounts != []
      lowest_threshold(item).first.item_threshold <= total_unique_item(item)
    else
      return false
    end
  end

  def discount_subtotal(item, total)
    total - (total * highest_discount_percent(item))
  end

  def highest_discount(item)
    total_item = total_unique_item(item)
    item.merchant.distinct_discounts.where('item_threshold <= ?', total_item).order(discount_percent: :desc).limit(1)
  end

  def highest_discount_percent(item)
    highest_discount(item).first.discount_percent.to_f/100
  end

  def lowest_threshold(item)
    item.merchant.distinct_discounts.order(:item_threshold).limit(1)
  end

  def total
    @contents.sum do |item_id,quantity|
      subtotal(Item.find(item_id))
    end
  end

  def inventory_check(item)
    @contents[item.id.to_s] < item.inventory
  end

  def price(item)
    if apply_discount?(item)
      item.price - (highest_discount_percent(item) * item.price)
    else
      item.price
    end
  end

end
