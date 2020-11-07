class CreateDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :discounts do |t|
      t.integer :discount_percent
      t.integer :item_threshold

      t.timestamps
    end
  end
end
