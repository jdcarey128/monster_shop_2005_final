require 'rails_helper'

describe 'as a merchant employee' do
  describe 'when I visit an order show page from my dashboard' do
    before :each do
      @merchant_1 = create(:merchant, :with_items, item_count: 3)
      @merchant_2 = create(:merchant, :with_items, item_count: 3)
      @user = create(:user)
      @merchant_employee = create(:user, role: 1, merchant_id: @merchant_1.id)

      @m1_item1 = @merchant_1.items[0]
      @m1_item1.inventory = 5
      @m1_item1.save

      @m1_item2 = @merchant_1.items[1]
      @m1_item3 = @merchant_1.items[2]
      @m2_item1 = @merchant_2.items[0]
      @m2_item2 = @merchant_2.items[1]
      @m2_item3 = @merchant_2.items[2]

      @order = create(:order, user: @user)
      @order_2 = create(:order, user: @user)

      @io1 = create(:item_order, order: @order, order_price: @m1_item1.price, item: @m1_item1, quantity: 2)
      @io2 = create(:item_order, order: @order, order_price: @m1_item2.price, item: @m1_item2, quantity: 35)
      @io3 = create(:item_order, order: @order, order_price: @m1_item3.price, item: @m1_item3)
      @io4 = create(:item_order, order: @order, order_price: @m2_item1.price, item: @m2_item1, quantity: 4)
      @io5 = create(:item_order, order: @order, order_price: @m2_item2.price, item: @m2_item2)

      @io6 = create(:item_order, order: @order_2, order_price: @m1_item1.price, item: @m1_item1, quantity: 2)
      @io7 = create(:item_order, order: @order_2, order_price: @m2_item2.price, item: @m2_item2)
      @io8 = create(:item_order, order: @order_2, order_price: @m2_item3.price, item: @m2_item3, quantity: 5)

      visit login_path
      fill_in :email, with: @merchant_employee.email
      fill_in :password, with: @merchant_employee.password
      click_button "Login"
      click_on "#{@order.id}"
    end

    it 'has the recipients name and address for this order' do
      within ".order-info" do
        expect(page).to have_content(@order.name)
        expect(page).to have_content(@order.address)
        expect(page).to have_content(@order.city)
        expect(page).to have_content(@order.state)
        expect(page).to have_content(@order.zip)
      end
    end

    it 'only shows items in the order from my merchant' do
      within ".order-items" do
        expect(page).to have_content(@m1_item1.name)
        expect(page).to have_content(@m1_item2.name)
        expect(page).to have_content(@m1_item3.name)
      end
    end

    it 'doesnt show any items being purchased from other merchants' do
      within ".order-items" do
        expect(page).to_not have_content(@m2_item1.name)
        expect(page).to_not have_content(@m2_item2.name)
      end
    end

    it 'shows linked name, image, price and quantity for each item' do
      within "#item-#{@m1_item1.id}" do
        expect(page).to have_content(@m1_item1.name)
        expect(page).to have_xpath("//img[contains(@src,'#{@m1_item1.image}')]")
        expect(page).to have_content(@m1_item1.price)
        expect(page).to have_content(2)
      end
    end

    it 'shows a button to fulfill items not already fulfilled' do
      within "#item-#{@m1_item1.id}" do
        expect(page).to have_button("Fulfill Item")
      end
    end

    it 'shows a button to fulfill items if desired quantity is equal to/less than inventory' do
      within "#item-#{@m1_item1.id}" do
        expect(page).to have_button("Fulfill Item")
      end

      within "#item-#{@m1_item2.id}" do
        expect(page).to_not have_button("Fulfill Item")
      end
    end

    it 'returns me to the order show page when I click the fulfill button & shows item is fulfilled' do
      within "#item-#{@m1_item1.id}" do
        click_button("Fulfill Item")
      end

      expect(current_path).to eq("/merchant/orders/#{@order.id}")

      within "#item-#{@m1_item1.id}" do
        expect(page).to have_content("Item already fulfilled.")
      end
    end

    it 'has a flash message indicating I have fulfilled that item' do
      within "#item-#{@m1_item1.id}" do
        click_button("Fulfill Item")
      end

      expect(page).to have_content("Item has been fulfilled")
    end

    it 'permanently reduces inventory quantity by users desired quantity' do
      within "#item-#{@m1_item1.id}" do
        click_button("Fulfill Item")
      end

      @m1_item1.reload
      expect(@m1_item1.inventory).to eq(3)
    end

    it 'has notice text next to item that I cannot fulfill item if users desired qty is greater than current inventory' do
      within "#item-#{@m1_item2.id}" do
        expect(page).to have_content("Cannot fulfill item: insufficient inventory")
      end
    end
  end
end
