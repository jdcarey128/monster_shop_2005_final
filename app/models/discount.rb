class Discount < ApplicationRecord
  validates_presence_of :discount_percent
  validates_presence_of :item_threshold
  has_many :item_discounts
  has_many :items, through: :item_discounts

  def apply_to_all_merchant_items(merchant_id)
    self.items << Merchant.find_by_id(merchant_id).items
  end


end
