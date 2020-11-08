require 'rails_helper'

RSpec.describe 'As a user', type: :feature do
  describe 'when I have submitted a discounted order' do
    it 'I see the discount price and total on the order show page' do
      user = create(:user)
      merchant = create(:merchant, :with_items, item_count: 1)
      item = merchant.items[0]
      discount = create(:discount, discount_percent: 10, item_threshold: 5)
      discount.items << item
      item_order = create(:item_order, quantity: 5, item: item)
      order = item_order.order

      visit login_path

      fill_in :email, with: user.email
      fill_in :password, with: 'password'
      click_button 'Login'

      visit profile_order_show_path(order)

      within "#item-#{item.id}" do
        expect(page).to have_content(item_order.discounted_price)
        expect(page).to have_content(item_order.discount_subtotal)
        expect(page).to_not have_content(item_order.price)
      end
    end

  end
end
