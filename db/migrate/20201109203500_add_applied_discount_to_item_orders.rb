class AddAppliedDiscountToItemOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :item_orders, :applied_discount?, :boolean, default: true 
  end
end
