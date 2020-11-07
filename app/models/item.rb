class Item < ApplicationRecord
  belongs_to :merchant
  has_many :reviews, dependent: :destroy
  has_many :item_orders
  has_many :orders, through: :item_orders
  has_many :item_discounts
  has_many :discounts, through: :item_discounts

  validates_presence_of :name,
                        :description,
                        :price,
                        :image,
                        :inventory
                        
  validates_inclusion_of :active?, :in => [true, false]
  validates_numericality_of :price, greater_than: 0
  validates_numericality_of :inventory, greater_than_or_equal_to: 0

  def self.most_popular_five
    Item.joins(:item_orders).select('items.*, sum(quantity) as total_quantity')
        .group(:id).order('total_quantity DESC').limit(5)
  end

  def self.least_popular_five
    Item.joins(:item_orders).select('items.*, sum(quantity) as total_quantity')
        .group(:id).order('total_quantity').limit(5)
  end

  def average_review
    reviews.average(:rating)
  end

  def sorted_reviews(limit, order)
    reviews.order(rating: order).limit(limit)
  end

  def no_orders?
    item_orders.empty?
  end

  def quantity_purchased
    item_orders.sum(:quantity)
  end

  def quantity_ordered(item_id)
    ItemOrder.where("item_id = ?", "#{item_id}").sum(:quantity)
  end

  def fulfilled?(order_id)
    item_orders.where(order_id: order_id).first.fulfill_status == 'fulfilled'
  end

  def insufficient_inventory?(order_id)
    item_orders.where(order_id: order_id).first.quantity > self.inventory
  end
end
