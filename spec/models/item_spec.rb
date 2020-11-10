require 'rails_helper'

describe Item, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :price }
    it { should validate_presence_of :image }
    it { should validate_presence_of :inventory }
    it { should allow_value(%w(true false)).for(:active?) }
  end

  describe "relationships" do
    it {should belong_to :merchant}
    it {should have_many :reviews}
    it {should have_many :item_orders}
    it {should have_many(:orders).through(:item_orders)}
    it {should have_many(:item_discounts)}
    it {should have_many(:discounts).through(:item_discounts)}
  end

  describe 'class methods' do
    it'.most_popular_five' do
      merchant = create(:merchant, :with_items, item_count: 12)
      create(:item_order, item: merchant.items[2], quantity: 6)
      create(:item_order, item: merchant.items[2], quantity: 6)
      create(:item_order, item: merchant.items[1], quantity: 8)
      create(:item_order, item: merchant.items[1], quantity: 8)
      create(:item_order, item: merchant.items[3], quantity: 4)
      create(:item_order, item: merchant.items[0], quantity: 10)
      create(:item_order, item: merchant.items[4], quantity: 3)

      create(:item_order, item: merchant.items[5], quantity: 2)
      create(:item_order, item: merchant.items[6], quantity: 1)
      create(:item_order, item: merchant.items[7], quantity: 1)

      expected = [merchant.items[1], merchant.items[2], merchant.items[0], merchant.items[3], merchant.items[4]]

      expect(Item.most_popular_five).to eq(expected)
    end

    it'.least_popular_five' do
      merchant = create(:merchant, :with_items, item_count: 12)
      create(:item_order, item: merchant.items[2], quantity: 20)
      create(:item_order, item: merchant.items[1], quantity: 18)
      create(:item_order, item: merchant.items[3], quantity: 16)
      create(:item_order, item: merchant.items[0], quantity: 10)
      create(:item_order, item: merchant.items[4], quantity: 9)

      create(:item_order, item: merchant.items[6], quantity: 7)
      create(:item_order, item: merchant.items[5], quantity: 8)
      create(:item_order, item: merchant.items[8], quantity: 2)
      create(:item_order, item: merchant.items[8], quantity: 2)
      create(:item_order, item: merchant.items[7], quantity: 3)
      create(:item_order, item: merchant.items[9], quantity: 1)
      create(:item_order, item: merchant.items[9], quantity: 1)

      expected = [merchant.items[9], merchant.items[7], merchant.items[8], merchant.items[6], merchant.items[5]]

      expect(Item.least_popular_five).to eq(expected)
    end
  end

  describe "instance methods" do
    before(:each) do
      @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @chain = @bike_shop.items.create(name: "Chain", description: "It'll never break!", price: 50, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 5)

      @review_1 = @chain.reviews.create(title: "Great place!", content: "They have great bike stuff and I'd recommend them to anyone.", rating: 5)
      @review_2 = @chain.reviews.create(title: "Cool shop!", content: "They have cool bike stuff and I'd recommend them to anyone.", rating: 4)
      @review_3 = @chain.reviews.create(title: "Meh place", content: "They have meh bike stuff and I probably won't come back", rating: 1)
      @review_4 = @chain.reviews.create(title: "Not too impressed", content: "v basic bike shop", rating: 2)
      @review_5 = @chain.reviews.create(title: "Okay place :/", content: "Brian's cool and all but just an okay selection of items", rating: 3)
    end

    it "#calculate average review" do
      expect(@chain.average_review).to eq(3.0)
    end

    it "#sorts reviews" do
      top_three = @chain.sorted_reviews(3,:desc)
      bottom_three = @chain.sorted_reviews(3,:asc)

      expect(top_three).to eq([@review_1,@review_2,@review_5])
      expect(bottom_three).to eq([@review_3,@review_4,@review_5])
    end

    it '#no orders' do
      expect(@chain.no_orders?).to eq(true)
      user = create(:user)
      order = Order.create(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, user_id: user.id)
      order.item_orders.create(item: @chain, order_price: @chain.price, quantity: 2)
      expect(@chain.no_orders?).to eq(false)
    end

    it '#amount_purchased' do
      merchant = create(:merchant, :with_items, item_count: 1)
      create(:item_order, item: merchant.items[0], quantity: 6)
      create(:item_order, item: merchant.items[0], quantity: 4)
      create(:item_order, item: merchant.items[0], quantity: 2)

      expect(merchant.items[0].quantity_purchased).to eq(12)
    end

    it '#quantity_ordered(id)' do
      user = create(:user)
      order_1 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, user_id: user.id)
      order_2 = Order.create!(name: 'Yo', address: 'Whatever', city: 'Place', state: 'PA', zip: 17033, user_id: user.id)
      order_1.item_orders.create!(item: @chain, order_price: @chain.price, quantity: 4)
      order_2.item_orders.create!(item: @chain, order_price: @chain.price, quantity: 3)

      expect(@chain.quantity_ordered(@chain.id)).to eq(7)
    end

    it '#fulfilled?(order_id)' do
      user = create(:user)
      order_1 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, user_id: user.id)
      order_2 = Order.create!(name: 'Yo', address: 'Whatever', city: 'Place', state: 'PA', zip: 17033, user_id: user.id)
      order_1.item_orders.create!(item: @chain, order_price: @chain.price, quantity: 4, fulfill_status: 'fulfilled')
      order_2.item_orders.create!(item: @chain, order_price: @chain.price, quantity: 3, fulfill_status: 'unfulfilled')

      expect(@chain.fulfilled?(order_1)).to eq(true)
      expect(@chain.fulfilled?(order_2)).to eq(false)
    end

    it '#insufficient_inventory?(order_id)' do
      user = create(:user)
      order_1 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, user_id: user.id)
      order_2 = Order.create!(name: 'Yo', address: 'Whatever', city: 'Place', state: 'PA', zip: 17033, user_id: user.id)
      order_1.item_orders.create!(item: @chain, order_price: @chain.price, quantity: 4, fulfill_status: 'fulfilled')
      order_2.item_orders.create!(item: @chain, order_price: @chain.price, quantity: 10, fulfill_status: 'unfulfilled')

      expect(@chain.insufficient_inventory?(order_2.id)).to eq(true)
      expect(@chain.insufficient_inventory?(order_1.id)).to eq(false)
    end

    describe '#item_order_price()' do
      it 'returns the item_order price for an item within a specific order' do
        item = create(:item, price: 20)

        order = create(:order)
        order_2 = create(:order)

        item_order = create(:item_order, item: item, order: order, quantity: 10)
        item_order_2 = create(:item_order, item: item, order: order_2, order_price: 10, quantity: 5)

        expect(item.item_order_price(order)).to eq(20)
        expect(item.item_order_price(order_2)).to eq(10)
      end
    end

    describe '#item_order_quantity()' do
      it 'returns the item_order quantity for an item within a specific order' do
        item = create(:item, price: 20)

        order = create(:order)
        order_2 = create(:order)

        item_order = create(:item_order, item: item, order: order, quantity: 10)
        item_order_2 = create(:item_order, item: item, order: order_2, order_price: 10, quantity: 5)

        expect(item.item_order_quantity(order)).to eq(10)
        expect(item.item_order_quantity(order_2)).to eq(5)
      end
    end
  end
end
