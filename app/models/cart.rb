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

  def total_unique_item(item)
    @contents[item.id.to_s]
  end

  def apply_discount?(item)
    if item.merchant.discounts != []
      item.merchant.distinct_discounts.order(:item_threshold).limit(1).first.item_threshold <= total_unique_item(item)
    else
      return false
    end
  end

  def items
    item_quantity = {}
    @contents.each do |item_id,quantity|
      item_quantity[Item.find(item_id)] = quantity
    end
    item_quantity
  end

  def subtotal(item)
    total = item.price * total_unique_item(item)
    return discount_subtotal(item, total) if apply_discount?(item)
    return total
  end

  def discount_subtotal(item, total)
    total - (total * (item.merchant.distinct_discounts.order(:item_threshold).limit(1).first.discount_percent.to_f/100))
  end

  def total
    #maybe refactor this to account for discount
    @contents.sum do |item_id,quantity|
      Item.find(item_id).price * quantity
    end
  end

  def inventory_check(item)
    @contents[item.id.to_s] < item.inventory
  end

end
