require 'rails_helper'

describe ItemOrder, type: :model do
  describe "validations" do
    it { should validate_presence_of :order_id }
    it { should validate_presence_of :item_id }
    it { should validate_presence_of :order_price }
    it { should validate_presence_of :quantity }
  end

  describe "relationships" do
    it {should belong_to :item}
    it {should belong_to :order}
  end

  describe 'class methods' do
    describe '.unique_items' do
      it "returns unique items for a merchant's item_orders" do
        merchant = create(:merchant, :with_items, item_count: 12)
        create(:item_order, item: merchant.items[2])
        create(:item_order, item: merchant.items[1])
        create(:item_order, item: merchant.items[3])
        create(:item_order, item: merchant.items[3])

        expect(ItemOrder.unique_items).to eq(3)
      end

      it "returns unique items for more than one merchant" do
        merchant = create(:merchant, :with_items, item_count: 3)
        merchant_2 = create(:merchant, :with_items, item_count: 4)

        create(:item_order, item: merchant.items[2])
        create(:item_order, item: merchant.items[1])
        create(:item_order, item: merchant.items[0])
        create(:item_order, item: merchant.items[0])
        create(:item_order, item: merchant_2.items[3])
        create(:item_order, item: merchant_2.items[3])
        create(:item_order, item: merchant_2.items[2])
        create(:item_order, item: merchant_2.items[1])

        expect(ItemOrder.unique_items).to eq(6)
      end
    end
  end

  describe 'instance methods' do
    describe "#subtotal" do
      it "can return the subtotal for an item order" do
        meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
        tire = meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
        user = create(:user)
        order_1 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, user_id: user.id)
        item_order_1 = order_1.item_orders.create!(item: tire, order_price: tire.price, quantity: 2)

        expect(item_order_1.subtotal).to eq(200)
      end

      it 'it can return the subtotal with multiple item_orders' do
        meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
        tire = meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
        user = create(:user)
        order_1 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, user_id: user.id)
        item_order_1 = order_1.item_orders.create!(item: tire, order_price: tire.price, quantity: 2)
        item_order_2 = order_1.item_orders.create!(item: tire, order_price: tire.price, quantity: 1)

        expect(item_order_2.subtotal).to eq(100)
      end

    end
  end

end
