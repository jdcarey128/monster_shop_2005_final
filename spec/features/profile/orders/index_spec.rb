require 'rails_helper'

describe 'as a default user' do
  before :each do
    @merchant = Merchant.create!(name: "Big Bertha's Monster Depot", address: "Beyond the Firey Pit", city: "Hell-Adjacent", state: "Arizona", zip: "66666")
    @user = create(:user)
    @gelatinous_cube = @merchant.items.create(name: "Gelatinous Cube", description: "A ten-foot cube of transparent gelatinous ooze.", price: 100, image: "https://www.epicpath.org/images/thumb/8/80/Gelatinous_cube.jpg/550px-Gelatinous_cube.jpg", inventory: 10)
    @owlbear = @merchant.items.create(name: "Owlbear", description: "A cross between a bear and an owl. Owlbear.", price: 1000, image: "https://static.wikia.nocookie.net/forgottenrealms/images/4/43/Monster_Manual_5e_-_Owlbear_-_p249.jpg/revision/latest?cb=20141113191357", inventory: 1)
    @beholder = @merchant.items.create(name: "Beholder", description: "A floating orb of flesh with a large mouth, single central eye and many smaller eyestalks on top.", price: 10000, image: "https://static.wikia.nocookie.net/forgottenrealms/images/2/2c/Monster_Manual_5e_-_Beholder_-_p28.jpg/revision/latest?cb=20200313153220", inventory: 1)
    @order_1 = @user.orders.create!(name: 'Shaunda', address: '123 Superduper Lane', city: 'Cooltown', state: 'CO', zip: 80247)
    @item_order_1 = @order_1.item_orders.create!(item: @gelatinous_cube, order_price: @gelatinous_cube.price, quantity: 1)
    @item_order_2 = @order_1.item_orders.create!(item: @owlbear, order_price: @owlbear.price, quantity: 2)
    @order_2 = @user.orders.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033)
    @item_order_3 = @order_2.item_orders.create!(item: @beholder, order_price: @beholder.price, quantity: 1)
  end

  describe 'when I visit my profile orders page' do
    it 'has every order I have made with all details' do
      visit login_path
      fill_in :email, with: @user.email
      fill_in :password, with: @user.password
      click_button "Login"
      click_link "My Orders"

      within "#order-#{@order_1.id}" do
        expect(page).to have_link("#{@order_1.id}")
        expect(page).to have_content(@order_1.status)
        expect(page).to have_content(@order_1.total_quantity)
        expect(page).to have_content("$2,100.00")
      end

      within "#order-#{@order_2.id}" do
        expect(page).to have_link("#{@order_2.id}")
        expect(page).to have_content(@order_2.status)
        expect(page).to have_content(@order_2.total_quantity)
        expect(page).to have_content("$10,000.00")
      end
    end
  end

  describe 'from the profile/orders page when I click on a link for orders show page' do
    it 'has all information about that specific order' do
      visit login_path
      fill_in :email, with: @user.email
      fill_in :password, with: @user.password
      click_button "Login"
      click_link "My Orders"

      within "#order-#{@order_1.id}" do
        click_link("#{@order_1.id}")
      end

      expect(current_path).to eq("/profile/orders/#{@order_1.id}")

      within ".order-info" do
        expect(page).to have_content(@order_1.id)
        expect(page).to have_content(@order_1.status)
        expect(page).to have_content(@order_1.total_quantity)
      end

      within "#item-#{@gelatinous_cube.id}" do
        expect(page).to have_content(@gelatinous_cube.name)
        expect(page).to have_content(@gelatinous_cube.description)
        expect(page).to have_xpath("//img[contains(@src,'#{@gelatinous_cube.image}')]")
        expect(page).to have_content(@item_order_1.quantity)
      end
      within "#item-#{@owlbear.id}" do
        expect(page).to have_content(@owlbear.name)
      end
    end
  end
end
