class AddDiscountedPriceToItemOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :item_orders, :discounted_price, :float
  end
end
