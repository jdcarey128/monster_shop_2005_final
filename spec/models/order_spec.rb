require 'rails_helper'

describe Order, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
  end

  describe "relationships" do
    it {should have_many :item_orders}
    it {should have_many(:items).through(:item_orders)}
    it {should belong_to :user}
  end

  describe 'instance methods' do
    before :each do
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @brian = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)

      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @pull_toy = @brian.items.create(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)
      @user = create(:user)
      @order_1 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, user_id: @user.id)

      @item_order_1 = @order_1.item_orders.create!(item: @tire, order_price: @tire.price, quantity: 2)
      @item_order_2 = @order_1.item_orders.create!(item: @pull_toy, order_price: @pull_toy.price, quantity: 3)
    end

    it '#grandtotal' do
      expect(@order_1.grandtotal).to eq(230)

      @chew_toy = @meg.items.create(name: "Chew Toy", description: "Great chew toy!", price: 20, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 15)
      @item_order_3 = @order_1.item_orders.create!(item: @chew_toy, order_price: @chew_toy.price, quantity: 4)

      expect(@order_1.grandtotal).to eq(310)
    end

    it '#total_quantity' do
      expect(@order_1.total_quantity).to eq(5)

      @chew_toy = @meg.items.create(name: "Chew Toy", description: "Great chew toy!", price: 20, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 15)
      @item_order_3 = @order_1.item_orders.create!(item: @chew_toy, order_price: @chew_toy.price, quantity: 4)

      expect(@order_1.total_quantity).to eq(9)
    end

    describe '#status_check' do
      it 'will return packaged if all statuses are fulfilled for order' do
        @item_order_1.fulfill_status = "fulfilled"
        @item_order_1.save
        @item_order_2.fulfill_status = "fulfilled"
        @item_order_2.save
        expect(@order_1.status_check).to eq("packaged")
      end

      it 'will return pending if all statuses are not fulfilled' do
        @item_order_1.fulfill_status = "unfulfilled"
        @item_order_1.save
        @item_order_2.fulfill_status = "fulfilled"
        @item_order_2.save
        expect(@order_1.status_check).to eq("pending")
      end
    end

    describe "#all_fullfilled?" do
      it "returns true if all item_orders within an order are fulfilled" do
        @item_order_1.fulfill_status = "fulfilled"
        @item_order_1.save
        @item_order_2.fulfill_status = "fulfilled"
        @item_order_2.save
        expect(@order_1.all_fulfilled?).to eq(true)
      end

      it "returns false if one or more item_orders within an order are not fulfilled" do
        @item_order_1.fulfill_status = "unfulfilled"
        @item_order_1.save
        @item_order_2.fulfill_status = "fulfilled"
        @item_order_2.save
        expect(@order_1.all_fulfilled?).to eq(false)

        @item_order_2.fulfill_status = "unfulfilled"
        expect(@order_1.all_fulfilled?).to eq(false)
      end
    end

    describe "#merchant_items" do
      it "returns only an item belonging to the merchant" do
        @chew_toy = @meg.items.create(name: "Chew Toy", description: "Great chew toy!", price: 20, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 15)
        @item_order_3 = @order_1.item_orders.create!(item: @chew_toy, order_price: @chew_toy.price, quantity: 4)

        expect(@order_1.merchant_items(@meg.id).first.name).to eq(@tire.name)
        expect(@order_1.merchant_items(@meg.id).first.description).to eq(@tire.description)
        expect(@order_1.merchant_items(@meg.id).first.order_price).to eq(@item_order_1.order_price)
        expect(@order_1.merchant_items(@meg.id).first.quantity).to eq(@item_order_1.quantity)

        expect(@order_1.merchant_items(@meg.id).second.name).to eq(@chew_toy.name)
        expect(@order_1.merchant_items(@meg.id).second.description).to eq(@chew_toy.description)
        expect(@order_1.merchant_items(@meg.id).second.order_price).to eq(@item_order_3.order_price)
        expect(@order_1.merchant_items(@meg.id).second.quantity).to eq(@item_order_3.quantity)

        expect(@order_1.merchant_items(@brian.id).first.name).to eq(@pull_toy.name)
        expect(@order_1.merchant_items(@brian.id).first.description).to eq(@pull_toy.description)
        expect(@order_1.merchant_items(@brian.id).first.order_price).to eq(@item_order_2.order_price)
        expect(@order_1.merchant_items(@brian.id).first.quantity).to eq(@item_order_2.quantity)
      end

      it "returns items with discounted prices" do
        @chew_toy = @meg.items.create(name: "Chew Toy", description: "Great chew toy!", price: 20, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 15)
        @item_order_3 = @order_1.item_orders.create!(item: @chew_toy, order_price: 15, quantity: 4)

        expect(@order_1.merchant_items(@meg.id).second.name).to eq(@chew_toy.name)
        expect(@order_1.merchant_items(@meg.id).second.description).to eq(@chew_toy.description)
        expect(@order_1.merchant_items(@meg.id).second.order_price).to eq(15)
        expect(@order_1.merchant_items(@meg.id).second.quantity).to eq(@item_order_3.quantity)
      end
    end

  end
end
