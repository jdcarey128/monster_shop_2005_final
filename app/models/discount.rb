class Discount < ApplicationRecord
  validates_presence_of :discount_percent
  validates_presence_of :item_threshold
  has_many :item_discounts
  has_many :items, through: :item_discounts
  validates_numericality_of :discount_percent, greater_than: 0, less_than_or_equal_to: 100
  validates_numericality_of :item_threshold, greater_than: 0, less_than_or_equal_to: 100

  def apply_to_all_merchant_items(merchant_id)
    self.items << Merchant.find_by_id(merchant_id).items
  end

end
