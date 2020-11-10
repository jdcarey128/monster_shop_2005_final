require 'rails_helper'

describe 'As an admin user' do
  describe 'on my admin dashboard page' do
    before :each do
      @admin = create(:user, role: 2)
      @merchant = Merchant.create!(name: "Big Bertha's Monster Depot", address: "Beyond the Firey Pit", city: "Hell-Adjacent", state: "Arizona", zip: "66666")
      @user = create(:user)
      @gelatinous_cube = Item.create(name: "Gelatinous Cube", description: "A ten-foot cube of transparent gelatinous ooze.", price: 100, image: "https://www.epicpath.org/images/thumb/8/80/Gelatinous_cube.jpg/550px-Gelatinous_cube.jpg", inventory: 10)
      @owlbear = Item.create(name: "Owlbear", description: "A cross between a bear and an owl. Owlbear.", price: 1000, image: "https://static.wikia.nocookie.net/forgottenrealms/images/4/43/Monster_Manual_5e_-_Owlbear_-_p249.jpg/revision/latest?cb=20141113191357", inventory: 15)
      @beholder = Item.create(name: "Beholder", description: "A floating orb of flesh with a large mouth, single central eye and many smaller eyestalks on top.", price: 10000, image: "https://static.wikia.nocookie.net/forgottenrealms/images/2/2c/Monster_Manual_5e_-_Beholder_-_p28.jpg/revision/latest?cb=20200313153220", inventory: 5)
      @merchant.items << @gelatinous_cube
      @merchant.items << @owlbear
      @merchant.items << @beholder

      @order_1 = Order.create!(name: 'Shaunda', address: '123 Superduper Lane', city: 'Cooltown', state: 'CO', zip: 80247, user_id: @user.id, status: "pending")
      @order_2 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, user_id: @user.id, status: "pending")
      @order_3 = Order.create!(name: 'Shaunda', address: '123 Superduper Lane', city: 'Cooltown', state: 'CO', zip: 80247, user_id: @user.id, status: "packaged")
      @order_4 = Order.create!(name: 'Shaunda', address: '123 Superduper Lane', city: 'Cooltown', state: 'CO', zip: 80247, user_id: @user.id, status: "shipped")
      @order_5 = Order.create!(name: 'Shaunda', address: '123 Superduper Lane', city: 'Cooltown', state: 'CO', zip: 80247, user_id: @user.id, status: "cancelled")

      @item_order_1 = ItemOrder.create!(item: @gelatinous_cube, order_price: @gelatinous_cube.price, quantity: 1, order_id: @order_1.id, item_id: @gelatinous_cube.id)
      @item_order_2 = ItemOrder.create!(item: @owlbear, order_price: @owlbear.price, quantity: 2, order_id: @order_1.id, item_id: @owlbear.id)
      @item_order_3 = ItemOrder.create!(item: @beholder, order_price: @beholder.price, quantity: 1, order_id: @order_2.id, item_id: @beholder.id)
      @item_order_4 = ItemOrder.create!(item: @gelatinous_cube, order_price: @gelatinous_cube.price, quantity: 3, order_id: @order_3.id, item_id: @gelatinous_cube.id)
      @item_order_5 = ItemOrder.create!(item: @gelatinous_cube, order_price: @gelatinous_cube.price, quantity: 1, order_id: @order_4.id, item_id: @gelatinous_cube.id)
      @item_order_6 = ItemOrder.create!(item: @owlbear, order_price: @owlbear.price, quantity: 5, order_id: @order_5.id, item_id: @owlbear.id)

      visit login_path
      fill_in :email, with: @admin.email
      fill_in :password, with: @admin.password
      click_button "Login"
    end

    it 'displays all orders in the system' do

      within ".all-orders" do
        expect(page).to have_content(@order_1.id)
        expect(page).to have_content(@order_2.id)
        expect(page).to have_content(@order_3.id)
        expect(page).to have_content(@order_4.id)
        expect(page).to have_content(@order_5.id)
      end
    end

    it 'has information for each order' do

      within "#order-#{@order_1.id}" do
        expect(page).to have_link(@user.name)
        expect(page).to have_content(@order_1.id)
        expect(page).to have_content(@order_1.created_at)
      end

      within "#order-#{@order_4.id}" do
        expect(page).to have_link(@user.name)
        expect(page).to have_content(@order_4.id)
        expect(page).to have_content(@order_4.created_at)
      end
    end

    it 'sorts the orders by status' do

      within ".packaged-orders" do
        expect(page).to have_link(@user.name)
        expect(page).to have_content(@order_3.id)
        expect(page).to have_content(@order_3.created_at)
      end

      within ".pending-orders" do
        expect(page).to have_link(@user.name)
        expect(page).to have_content(@order_1.id)
        expect(page).to have_content(@order_1.created_at)
        expect(page).to have_link(@user.name)
        expect(page).to have_content(@order_2.id)
        expect(page).to have_content(@order_2.created_at)
        expect(page).to_not have_content(@order_5.id, exact:true)
      end

      within ".shipped-orders" do
        expect(page).to have_link(@user.name)
        expect(page).to have_content(@order_4.id)
        expect(page).to have_content(@order_4.created_at)
      end

      within ".cancelled-orders" do
        expect(page).to have_link(@user.name)
        expect(page).to have_content(@order_5.id)
        expect(page).to have_content(@order_5.created_at)
      end
    end

    it 'can ship any packaged order and update order status to shipped' do
      within ".packaged-orders" do
        click_link("Ship Order")
      end

      expect(current_path).to eq("/admin")

      within ".shipped-orders" do
        expect(page).to have_content(@user.name)
      end
    end
  end
end
