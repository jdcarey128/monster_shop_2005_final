class Discount < ApplicationRecord
  validates_presence_of :discount_percent
  validates_presence_of :item_threshold
  has_many :item_discounts
  has_many :items, through: :item_discounts
end
