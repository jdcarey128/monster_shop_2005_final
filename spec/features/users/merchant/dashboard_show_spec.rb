require 'rails_helper'

describe 'As a merchant employee' do
  describe 'when I log in and visit the merchant dashboard' do

    it "I see the name and full address of the merchant I work for" do
      merchant = create(:merchant)
      merchant_user = create(:user, role: 1, merchant_id: merchant.id)

      visit login_path

      fill_in :email, with: merchant_user.email
      fill_in :password, with: 'password'
      click_button 'Login'

      expect(current_path).to eq('/merchant')

      within ".merchant-info" do
        expect(page).to have_content(merchant.name)
        expect(page).to have_content(merchant.address)
        expect(page).to have_content(merchant.city)
        expect(page).to have_content(merchant.state)
        expect(page).to have_content(merchant.zip)
      end
    end

    it "I see a list of pending orders" do
      item_order = create(:item_order)

      merchant = item_order.item.merchant
      merchant_user = create(:user, role: 1, merchant_id: merchant.id)
      order_1 = item_order.order

      user = create(:user)
      item_2 = create(:item, merchant: merchant)
      order_2 = create(:order, user: user, status: "packaged")
      item_order_2 = create(:item_order, item: item_2, order: order_2)
      order_1_date = order_1.created_at.strftime("%m/%d/%Y")
      visit login_path

      fill_in :email, with: merchant_user.email
      fill_in :password, with: 'password'
      click_button 'Login'

      within ".pending-orders" do
        expect(page).to have_css(".order", count:1)
        expect(page).to_not have_css("#order-#{order_2.id}")
      end

      within "#order-#{order_1.id}" do
        expect(page).to have_link("#{order_1.id}")
        expect(page).to have_content(order_1_date)
        expect(page).to have_content(order_1.total_quantity)
        expect(page).to have_content(order_1.grandtotal)
        click_link "#{order_1.id}"
      end

      expect(current_path).to eq("/merchant/orders/#{order_1.id}")
    end

    describe 'each pending order' do
      before :each do
        @merchant = create(:merchant, :with_items, item_count:3)
        @merchant_user = create(:user, role: 1, merchant_id: @merchant.id)
        @item_1 = @merchant.items[0]
        @item_2 = @merchant.items[1]
        @item_3 = @merchant.items[2]
        @order_1 = create(:order)
        @order_2 = create(:order)

        @item_order_1 = create(:item_order, item: @item_1, order: @order_1, quantity: 2)
        @item_order_2 = create(:item_order, item: @item_2, order: @order_1, quantity: 2)
        @item_order_3 = create(:item_order, item: @item_2, order: @order_2, quantity: 3)
        @item_order_4 = create(:item_order, item: @item_3, order: @order_2)

        @order_1_date = @order_1.created_at.strftime("%m/%d/%Y")
        @order_2_date = @order_2.created_at.strftime("%m/%d/%Y")

        @order_1_cost = ('$' + '%.2f' % ((@item_1.price * 2) + (@item_2.price * 2)))
        @order_2_cost = ('$' + '%.2f' % ((@item_2.price * 3) + @item_3.price))
      end

      it 'displays the order date, quantity of merchant items in order, and total for merchant items' do
        visit login_path

        fill_in :email, with: @merchant_user.email
        fill_in :password, with: 'password'
        click_button 'Login'

        expect(current_path).to eq(merchant_root_path)

        within '.pending-orders' do
          expect(page).to have_css('.order', count:2)
        end

        within "#order-#{@order_1.id}" do
          expect(page).to have_content(@order_1_date)
          expect(page).to have_content("Order quantity: 4")
          expect(page).to have_content("Order total: #{@order_1_cost}")
        end

        within "#order-#{@order_2.id}" do
          expect(page).to have_content(@order_2_date)
          expect(page).to have_content("Order quantity: 4")
          expect(page).to have_content("Order total: #{@order_2_cost}")
        end

      end

      it 'displays only the order information for the specified merchant' do
        @merchant_2 = create(:merchant, :with_items, item_count:2)
        @item_4 = @merchant_2.items[0]
        @item_5 = @merchant_2.items[1]

        @item_order_4 = create(:item_order, item: @item_4, order: @order_1, quantity: 2)
        @item_order_5 = create(:item_order, item: @item_5, order: @order_1, quantity: 1)
        @item_order_6 = create(:item_order, item: @item_5, order: @order_2, quantity: 1)

        visit login_path

        fill_in :email, with: @merchant_user.email
        fill_in :password, with: 'password'
        click_button 'Login'

        expect(current_path).to eq(merchant_root_path)

        within '.pending-orders' do
          expect(page).to have_css('.order', count:2)
        end

        within "#order-#{@order_1.id}" do
          expect(page).to have_content(@order_1_date)
          expect(page).to have_content("Order quantity: 4")
          expect(page).to have_content("Order total: #{@order_1_cost}")
        end

        within "#order-#{@order_2.id}" do
          expect(page).to have_content(@order_2_date)
          expect(page).to have_content("Order quantity: 4")
          expect(page).to have_content("Order total: #{@order_2_cost}")
        end

      end
    end

    it "I can click a link to merchant items" do
      merchant = create(:merchant)
      merchant_user = create(:user, role:1, merchant_id: merchant.id)

      visit login_path

      fill_in :email, with: merchant_user.email
      fill_in :password, with: 'password'
      click_button 'Login'

      click_link "My Items"

      expect(current_path).to eq("/merchant/items")
    end

  end
end
