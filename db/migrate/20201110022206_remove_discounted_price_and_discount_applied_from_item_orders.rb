class RemoveDiscountedPriceAndDiscountAppliedFromItemOrders < ActiveRecord::Migration[5.2]
  def change
    remove_columns(:item_orders, :discounted_price, :applied_discount?)
  end
end
