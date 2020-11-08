class ItemOrder <ApplicationRecord
  validates_presence_of :item_id, :order_id, :price, :quantity
  scope :fulfilled, -> { where('fulfill_status = ?', "fulfilled")}

  belongs_to :item
  belongs_to :order

  scope :fulfilled, -> { where('fulfill_status = ?', "fulfilled")}

  def self.unique_items
    select(:item_id).distinct.count
  end

  def subtotal
    return discounted_subtotal() if discount_applied?
    price * quantity
  end

  def discounted_subtotal
    discounted_price * quantity
  end

end
