require 'rails_helper'

RSpec.describe "As an admin" do
  describe "When I visit the merchant items page" do
    before(:each) do
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @chain = @meg.items.create(name: "Chain", description: "It'll never break!", price: 50, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 5)
      @shifter = @meg.items.create(name: "Shimano Shifters", description: "It'll always shift!", active?: false, price: 180, image: "https://images-na.ssl-images-amazon.com/images/I/4142WWbN64L._SX466_.jpg", inventory: 2)

      @user = create(:user, role: 2)
      visit login_path
      fill_in :email, with: @user.email
      fill_in :password, with: 'password'
      click_button "Login"
    end

    it 'shows me a list of that merchants items' do
      visit "/admin/merchants/#{@meg.id}/items"

      within "#item-#{@tire.id}" do
        expect(page).to have_content(@tire.name)
        expect(page).to have_content("Price: $#{@tire.price}")
        expect(page).to have_css("img[src*='#{@tire.image}']")
        expect(page).to have_content("Active")
        expect(page).to_not have_content(@tire.description)
        expect(page).to have_content("Inventory: #{@tire.inventory}")
      end

      within "#item-#{@chain.id}" do
        expect(page).to have_content(@chain.name)
        expect(page).to have_content("Price: $#{@chain.price}")
        expect(page).to have_css("img[src*='#{@chain.image}']")
        expect(page).to have_content("Active")
        expect(page).to_not have_content(@chain.description)
        expect(page).to have_content("Inventory: #{@chain.inventory}")
      end

      within "#item-#{@shifter.id}" do
        expect(page).to have_content(@shifter.name)
        expect(page).to have_content("Price: $#{@shifter.price}")
        expect(page).to have_css("img[src*='#{@shifter.image}']")
        expect(page).to have_content("Inactive")
        expect(page).to_not have_content(@shifter.description)
        expect(page).to have_content("Inventory: #{@shifter.inventory}")
      end
    end

    it 'gives me a link to deactivate active items' do
      visit "/admin/merchants/#{@meg.id}/items"

      within "#item-#{@shifter.id}" do
        expect(page).to have_content("Inactive")
        expect(page).to_not have_link('Deactivate')
      end

      within "#item-#{@chain.id}" do
        expect(page).to have_content("Active")
        click_on 'Deactivate'
      end

      expect(current_path).to eq("/admin/merchants/#{@meg.id}/items")
      expect(page).to have_content('This item is no longer for sale.')

      within "#item-#{@chain.id}" do
        expect(page).to have_content("Inactive")
        expect(page).to_not have_link('Deactivate')
      end
    end

    it 'gives me a link to activate inactive items' do
      visit "/admin/merchants/#{@meg.id}/items"

      within "#item-#{@chain.id}" do
        expect(page).to have_content("Active")
        expect(page).to_not have_link('Activate')
      end

      within "#item-#{@shifter.id}" do
        expect(page).to have_content("Inactive")
        click_on 'Activate'
      end

      expect(current_path).to eq("/admin/merchants/#{@meg.id}/items")
      expect(page).to have_content('This item is available for sale.')

      within "#item-#{@shifter.id}" do
        expect(page).to have_content("Active")
        expect(page).to_not have_link('Activate')
      end
    end

    it 'gives me the ability to delete an item never ordered' do

      order = @user.orders.create(
        name: @user.name,
        address: @user.street_address,
        city: @user.city,
        state: @user.state,
        zip: @user.zip
      )
      ItemOrder.create!(
        order_id: order.id,
        item_id: @tire.id,
        order_price: @tire.price,
        quantity: 1
      )

      visit "/admin/merchants/#{@meg.id}/items"

      within "#item-#{@tire.id}" do
        expect(page).to_not have_button("Delete")
      end

      within "#item-#{@shifter.id}" do
        expect(page).to have_content("Inactive")
        expect(page).to have_button("Delete")
      end

      within "#item-#{@chain.id}" do
        expect(page).to have_content("Active")
        click_on 'Delete'
      end

      expect(current_path).to eq("/admin/merchants/#{@meg.id}/items")
      expect(page).to have_content('This item is now deleted.')
      expect(page).to_not have_content(@chain.name)
    end

    it "I don't see other merchant items" do
      visit "/admin/merchants/#{@meg.id}/items"

      brian = Merchant.create!(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)
      item = brian.items.create!(name: "The Bone", description: "Can't destroy it!", price: 52, image: "https://dogtime.com/assets/uploads/2017/06/bones-safe-for-dogs-1.jpg", inventory: 5)

      expect(page).to_not have_content(item.name)
      expect(page).to_not have_content(item.description)
    end
  end
end
