require 'rails_helper'

RSpec.describe("Profile Order Page") do
  describe "When I check out from my cart" do
    before(:each) do
      @user = create(:user)
      @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @paper = @mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 25)
      @pencil = @mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 5, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)
      @discount = create(:discount, discount_percent: 10, item_threshold: 5)
      @discount.items << @mike.items

      visit login_path
      fill_in :email, with: @user.email
      fill_in :password, with: "password"
      click_button "Login"

      visit "/items/#{@paper.id}"
      click_on "Add To Cart"
      visit "/items/#{@tire.id}"
      click_on "Add To Cart"
      visit "/items/#{@pencil.id}"
      click_on "Add To Cart"

      visit "/cart"

      within "#cart-item-#{@paper.id}" do
        click_button "+"
        click_button "+"
        click_button "+"
        click_button "+"
      end

      within "#cart-item-#{@pencil.id}" do
        click_button "+"
        click_button "+"
        click_button "+"
        click_button "+"
      end

      click_button "Checkout"

      name = "Bert"
      address = "123 Sesame St."
      city = "NYC"
      state = "New York"
      zip = 10001

      fill_in :name, with: name
      fill_in :address, with: address
      fill_in :city, with: city
      fill_in :state, with: state
      fill_in :zip, with: zip

      click_button "Create Order"

      @order = Order.last
    end

    it "when I create an order, my '/profile/orders' reflects the discounted grand total" do
      expect(current_path).to eq(profile_orders_path)

      discounted_grandtotal = ('$' + '%.2f' % (22.5 + 90 + 100))

      within "#order-#{@order.id}" do
        expect(page).to have_content(discounted_grandtotal)
      end
    end




  end
end
