require 'rails_helper'

RSpec.describe 'As a user', type: :feature do
  describe 'when I go to the order show page with a discounted item' do
    before :each do
      @user = create(:user)
      @merchant = create(:merchant, :with_items, item_count: 2)
      @merchant_2 = create(:merchant, :with_items, item_count: 3)
      @item_1 = @merchant.items[0]
      @item_2 = @merchant.items[1]
      @item_3 = @merchant_2.items[0]
      @item_4 = @merchant_2.items[1]
      @item_5 = @merchant_2.items[2]
      @discount = create(:discount, discount_percent: 10, item_threshold: 5)
      @discount.items << @item_1
      @order = create(:order, user: @user)
      @item_order = create(:item_order, quantity: 5, order: @order, item: @item_1, discounted_price: 10, discount_applied?: true)

      visit login_path

      fill_in :email, with: @user.email
      fill_in :password, with: 'password'
      click_button 'Login'
    end

    it 'I see the discounted price and subtotal within the item listings' do
      visit profile_order_show_path(@order)

      within "#item-#{@item_1.id}" do
        expect(page).to have_content(@item_order.discounted_price)
        expect(page).to have_content(@item_order.discounted_subtotal)
        expect(page).to_not have_content(@item_order.price)
      end
    end

    it 'I see multiple discounted items listed with their discounts and subtotals' do
      @discount.items << @item_2
      @discount.items << @item_3
      @item_order_2 = create(:item_order, order: @order, item: @item_2, quantity: 5, discounted_price: 20, discount_applied?: true)
      @item_order_3 = create(:item_order, order: @order, item: @item_3, quantity: 10, discounted_price: 50, discount_applied?: true)

      visit profile_order_show_path(@order)

      within ".discounted-items" do
        expect(page).to have_css('.item', count:3)
      end

      within "#item-#{@item_2.id}" do
        expect(page).to have_content(@item_order_2.discounted_price)
        expect(page).to have_content(@item_order_2.discounted_subtotal)
        expect(page).to_not have_content(@item_order_2.price)
        expect(page).to_not have_content(@item_order_2.item.price)
      end

      within "#item-#{@item_3.id}" do
        expect(page).to have_content(@item_order_3.discounted_price)
        expect(page).to have_content(@item_order_3.discounted_subtotal)
        expect(page).to_not have_content(@item_order_3.price)
        expect(page).to_not have_content(@item_order_3.item.price)
      end
    end

    it 'I see items that were sold at full price and their full subtotals' do
      @item_order_2 = create(:item_order, order: @order, item: @item_2, quantity: 5)
      @item_order_3 = create(:item_order, order: @order, item: @item_3, quantity: 10)

      visit profile_order_show_path(@order)

      save_and_open_page
      within ".discounted-items" do
        expect(page).to have_css('.item', count:1)
      end

      within ".full-price-items" do
        expect(page).to have_css('.item', count:2)
      end

      within "#item-#{@item_2.id}" do
        expect(page).to have_content(@item_order_2.price)
        expect(page).to have_content(@item_order_2.subtotal)
      end
    end

    it 'I see a Grand Total that equals the sum item subtotals including discounted items' do
      
    end

  end
end
