require 'rails_helper'

RSpec.describe "As a user" do
  describe "when I add enough items into my cart to cross the discount threshold" do
    it "the discount will apply automatically" do
      user = create(:user)
      merchant = create(:merchant, :with_items, item_count: 3)
      item_1 = merchant.items[0]
      item_2 = merchant.items[1]
      item_3 = merchant.items[2]
      items = [item_1, item_2, item_3]
      discount = create(:discount, discount_percent: 10, item_threshold: 5)
      discount.items << items
      item_1_price = item_1.price
      item_2_price = item_2.price
      item_3_price = item_3.price

      visit login_path
      fill_in :email, with: user.email
      fill_in :password, with: 'password'
      click_button 'Login'

      visit item_path(item_1)
      click_button "Add To Cart"

      visit cart_path
      within "#cart-item-#{item_1.id}" do
        click_button "+"
        click_button "+"
        click_button "+"
      end

      expected_price = '$' + '%.2f' % (item_1_price * 4).round(2)
      expected_discount = '$' + '%.2f' % ((item_1_price * 5) - (item_1_price * 5 * 0.1)).round(2)

      within "#subtotal-#{item_1.id}" do
        expect(page).to have_content(expected_price)
      end

      within "#cart-item-#{item_1.id}" do
        click_button "+"
      end

      save_and_open_page
      within "#subtotal-#{item_1.id}" do
        expect(page).to have_content(expected_discount)
        expect(page).to have_content("with applied bulk discount")
      end
    end
  end
end
