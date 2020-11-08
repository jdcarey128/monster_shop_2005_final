class AddDiscountAppliedToItemOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :item_orders, :discount_applied?, :boolean, default: false 
  end
end
