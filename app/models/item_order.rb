class ItemOrder <ApplicationRecord
  validates_presence_of :item_id, :order_id, :order_price, :quantity
  scope :fulfilled, -> { where('fulfill_status = ?', "fulfilled")}

  belongs_to :item
  belongs_to :order

  scope :fulfilled, -> { where('fulfill_status = ?', "fulfilled")}

  def self.unique_items
    select(:item_id).distinct.count
  end

  def subtotal
    order_price * quantity
  end
end
