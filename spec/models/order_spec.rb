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
      @order_2 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, user_id: @user.id)

      @item_order_1 = @order_1.item_orders.create!(item: @tire, price: @tire.price, quantity: 2)
      @item_order_2 = @order_1.item_orders.create!(item: @pull_toy, price: @pull_toy.price, quantity: 3)
    end

    describe '#grandtotal' do
      it 'calculates the grandtotal without discounted items' do
        expect(@order_1.grandtotal).to eq(230)

        @chew_toy = @meg.items.create(name: "Chew Toy", description: "Great chew toy!", price: 20, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 15)
        @item_order_3 = @order_1.item_orders.create!(item: @chew_toy, price: @chew_toy.price, quantity: 4)

        expect(@order_1.grandtotal).to eq(310)
      end

      it 'calculates the grandtotal with discounted items' do
        @item_order_1 = @order_2.item_orders.create!(item: @tire, price: @tire.price, quantity: 2, discounted_price: 80, discount_applied?: true)
        @item_order_2 = @order_2.item_orders.create!(item: @pull_toy, price: @pull_toy.price, quantity: 3, discounted_price: 5, discount_applied?: true)

        expect(@order_2.grandtotal).to eq(175)
      end


    end

    it '#total_quantity' do
      expect(@order_1.total_quantity).to eq(5)

      @chew_toy = @meg.items.create(name: "Chew Toy", description: "Great chew toy!", price: 20, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 15)
      @item_order_3 = @order_1.item_orders.create!(item: @chew_toy, price: @chew_toy.price, quantity: 4)

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
        @item_order_3 = @order_1.item_orders.create!(item: @chew_toy, price: @chew_toy.price, quantity: 4)

        expect(@order_1.merchant_items(@meg.id)).to eq([@tire, @chew_toy])
        expect(@order_1.merchant_items(@brian.id)).to eq([@pull_toy])
      end

      it "does not return items belonging to another merchant" do
        @chew_toy = @meg.items.create(name: "Chew Toy", description: "Great chew toy!", price: 20, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 15)
        @item_order_3 = @order_1.item_orders.create!(item: @chew_toy, price: @chew_toy.price, quantity: 4)

        expect(@order_1.merchant_items(@brian.id)).to_not eq([@tire, @chew_toy])
        expect(@order_1.merchant_items(@meg.id)).to_not eq([@pull_toy])
      end
    end

    describe "#discounted_item_orders" do
      before :each do
        @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
        @brian = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)

        @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
        @pull_toy = @brian.items.create(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)
        @kibble = @brian.items.create(name: "Kibble", description: "Salmon flavored", price: 45, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 30)
        @dragon = @brian.items.create(name: "Stuffed Dragon", description: "Great chew toy!", price: 20, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 22)

        @user = create(:user)
        @order_1 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, user_id: @user.id)
        @order_2 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, user_id: @user.id)

        @item_order_1 = @order_1.item_orders.create!(item: @tire, price: @tire.price, quantity: 2, discounted_price: 80, discount_applied?: true)
        @item_order_2 = @order_1.item_orders.create!(item: @pull_toy, price: @pull_toy.price, quantity: 3)
        @item_order_3 = @order_1.item_orders.create!(item: @kibble, price: @kibble.price, quantity: 3, discounted_price: 35, discount_applied?: true)
        @item_order_4 = @order_2.item_orders.create!(item: @pull_toy, price: @pull_toy.price, quantity: 3, discounted_price: 10, discount_applied?: true)

        @discounted_item_orders_1 = [@item_order_1, @item_order_3]
        @discounted_item_orders_2 = [@item_order_4]
      end

      it 'returns item_order objects that have an applied discount, regardless of merchant' do
        expect(@order_1.discounted_item_orders).to eq(@discounted_item_orders_1)
      end

      it 'returns only discounted item_order objects that are a part of the order' do
        expect(@order_1.discounted_item_orders).to eq(@discounted_item_orders_1)
        expect(@order_2.discounted_item_orders).to eq(@discounted_item_orders_2)
      end
    end

    describe "#full_price_item_orders" do
      before :each do
        @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
        @brian = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)

        @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
        @pull_toy = @brian.items.create(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)
        @kibble = @brian.items.create(name: "Kibble", description: "Salmon flavored", price: 45, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 30)
        @dragon = @brian.items.create(name: "Stuffed Dragon", description: "Great chew toy!", price: 20, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 22)

        @user = create(:user)
        @order_1 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, user_id: @user.id)
        @order_2 = Order.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033, user_id: @user.id)

        @item_order_1 = @order_1.item_orders.create!(item: @tire, price: @tire.price, quantity: 2)
        @item_order_2 = @order_1.item_orders.create!(item: @pull_toy, price: @pull_toy.price, quantity: 3)
        @item_order_3 = @order_1.item_orders.create!(item: @kibble, price: @kibble.price, quantity: 3, discounted_price: 35, discount_applied?: true)
        @item_order_4 = @order_2.item_orders.create!(item: @pull_toy, price: @pull_toy.price, quantity: 3, discounted_price: 10, discount_applied?: true)

        @full_price_item_orders_1 = [@item_order_1, @item_order_2]
        @full_price_item_orders_2 = []
      end

      it 'returns item_order objects that are full price, regardless of merchant' do
        expect(@order_1.full_price_item_orders).to eq(@full_price_item_orders_1)
      end

      it 'returns only full price item_order objects that are a part of the order' do
        expect(@order_1.full_price_item_orders).to eq(@full_price_item_orders_1)
        expect(@order_2.full_price_item_orders).to eq(@full_price_item_orders_2)
      end
    end

  end
end
