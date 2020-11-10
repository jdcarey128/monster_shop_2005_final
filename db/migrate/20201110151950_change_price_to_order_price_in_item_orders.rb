class ChangePriceToOrderPriceInItemOrders < ActiveRecord::Migration[5.2]
  def change
    rename_column :item_orders, :price, :order_price
  end
end
