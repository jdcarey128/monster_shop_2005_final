require 'rails_helper'

RSpec.describe Cart do
  describe 'Instance Methods' do
    before :each do
      @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', inventory: 5 )
      @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', inventory: 2 )
      @hippo = @brian.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', inventory: 3 )
      @cart = Cart.new({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2
        })
      @discount = create(:discount, discount_percent: 5, item_threshold: 5)
      @discount.items << @megan.items
    end

    it '.contents' do
      expect(@cart.contents).to eq({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2
        })
    end

    describe "#add_item()" do
      it '.it will add an item that doesnt exits' do
        @cart.add_item(@hippo.id.to_s)

        expect(@cart.contents).to eq({
          @ogre.id.to_s => 1,
          @giant.id.to_s => 2,
          @hippo.id.to_s => 1
          })
      end

      it '.it will add an item that doesnt exits' do
        @cart.add_item(@ogre.id.to_s)

        expect(@cart.contents).to eq({
          @ogre.id.to_s => 2,
          @giant.id.to_s => 2,
          })
      end
    end

    it ".remove_one()" do
      @cart.remove_one(@giant.id.to_s)

      expect(@cart.contents).to eq({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 1
        })

      @cart.remove_one(@giant.id.to_s)

      expect(@cart.contents).to eq({
        @ogre.id.to_s => 1
        })
    end

    it '.total_items' do
      expect(@cart.total_items).to eq(3)
    end

    it '.items' do
      expect(@cart.items).to eq({@ogre => 1, @giant => 2})
    end

    describe '#discounted_items' do
      it "it will return all discounted items in hash" do
        expect(@cart.discounted_items).to eq({@ogre => 1, @giant => 2})
      end

      it "it will return only discounted items" do
        @cart.add_item(@hippo.id.to_s)
        expect(@cart.discounted_items).to eq({@ogre => 1, @giant => 2})
      end
    end

    describe '.full_priced_items' do
      it "it will return all full price items in hash" do
        @cart.add_item(@hippo.id.to_s)
        expect(@cart.full_priced_items).to eq({@hippo => 1})
      end
    end

    it '.total' do
      expect(@cart.total).to eq(120)
    end

    it '.subtotal()' do
      expect(@cart.subtotal(@ogre)).to eq(20)
      expect(@cart.subtotal(@giant)).to eq(100)
    end

    it '.inventory_check(item)' do
      expect(@cart.inventory_check(@giant)).to eq(false)
      expect(@cart.inventory_check(@ogre)).to eq(true)
    end

    it '#total_unique_item' do
      expect(@cart.total_unique_item(@giant)).to eq(2)
      expect(@cart.total_unique_item(@ogre)).to eq(1)

      @cart.add_item(@giant.id.to_s)
      expect(@cart.total_unique_item(@giant)).to eq(3)
    end

    describe '#apply_discount?' do
      it 'should only apply discount to items that reach threshold' do
        @cart.add_item(@giant.id.to_s)
        @cart.add_item(@giant.id.to_s)
        expect(@cart.apply_discount?(@giant)).to eq(false)
        expect(@cart.apply_discount?(@ogre)).to eq(false)
        @cart.add_item(@giant.id.to_s)
        expect(@cart.apply_discount?(@giant)).to eq(true)
        expect(@cart.apply_discount?(@ogre)).to eq(false)
      end

      it 'should only apply discount to items of merchant with discount' do
        @cart.add_item(@giant.id.to_s)
        @cart.add_item(@giant.id.to_s)
        @cart.add_item(@giant.id.to_s)
        @cart.add_item(@hippo.id.to_s)
        @cart.add_item(@hippo.id.to_s)
        @cart.add_item(@hippo.id.to_s)
        @cart.add_item(@hippo.id.to_s)
        @cart.add_item(@hippo.id.to_s)
        expect(@cart.apply_discount?(@giant)).to eq(true)
        expect(@cart.apply_discount?(@hippo)).to eq(false)
      end

      it 'should apply discount if there are more items than threshold' do
        @cart.add_item(@giant.id.to_s)
        @cart.add_item(@giant.id.to_s)
        @cart.add_item(@giant.id.to_s)
        @cart.add_item(@giant.id.to_s)
        expect(@cart.apply_discount?(@giant)).to eq(true)
        @cart.add_item(@giant.id.to_s)
        expect(@cart.apply_discount?(@giant)).to eq(true)
      end
    end

    describe "#discount_subtotal" do
      before :each do
        @cart.add_item(@giant.id.to_s)
        @cart.add_item(@giant.id.to_s)
        @cart.add_item(@giant.id.to_s)

        @total = @cart.total_unique_item(@giant) * @giant.price
        percent_discount = (@discount.discount_percent/100.to_f)
        @total_discount = (@total - (@total * percent_discount))
      end

      it 'should calculate the discount for an item that reaches threshold' do
        expect(@cart.discount_subtotal(@giant, @total)).to eq(@total_discount)
        expect(@cart.subtotal(@giant)).to eq(@total_discount)
      end

      it 'should not calculate the discount for an item under threshold or from a different merchant' do
        @cart.add_item(@hippo.id.to_s)
        @cart.add_item(@hippo.id.to_s)
        @cart.add_item(@hippo.id.to_s)
        @cart.add_item(@hippo.id.to_s)
        @cart.add_item(@hippo.id.to_s)
        expected_price = @cart.total_unique_item(@hippo) * @hippo.price
        expect(@cart.subtotal(@hippo)).to eq(expected_price)
      end

      it 'should calculate the discount with the largest percentage off' do
        @cart.add_item(@giant.id.to_s)

        @discount_2 = create(:discount, discount_percent: 10, item_threshold: 6)
        @discount_2.items << @megan.items

        @total = @cart.total_unique_item(@giant) * @giant.price
        percent_discount_2 = (@discount_2.discount_percent/100.to_f)
        @total_discount_2 = (@total - (@total * percent_discount_2))

        expect(@cart.discount_subtotal(@giant, @total)).to eq(@total_discount_2)
        expect(@cart.subtotal(@giant)).to eq(@total_discount_2)
      end

      it 'should calculate the discount with the largest percentage off' do
        @discount_2 = create(:discount, discount_percent: 10, item_threshold: 4)
        @discount_2.items << @megan.items

        @total = @cart.total_unique_item(@giant) * @giant.price
        percent_discount_2 = (@discount_2.discount_percent/100.to_f)
        @total_discount_2 = (@total - (@total * percent_discount_2))

        expect(@cart.discount_subtotal(@giant, @total)).to eq(@total_discount_2)
        expect(@cart.subtotal(@giant)).to eq(@total_discount_2)
      end
    end

    it '#lowest_threshold' do
      @discount_2 = create(:discount, discount_percent: 10, item_threshold: 6)
      @discount_2.items << @megan.items

      expect(@cart.lowest_threshold(@giant).first).to eq(@discount)

      @discount_3 = create(:discount, discount_percent: 10, item_threshold: 2)
      @discount_3.items << @megan.items

      expect(@cart.lowest_threshold(@giant).first).to eq(@discount_3)
    end

    it '#highest_discount' do
      @cart.add_item(@giant.id.to_s)
      @cart.add_item(@giant.id.to_s)
      @cart.add_item(@giant.id.to_s)
      @cart.add_item(@giant.id.to_s)

      @discount_2 = create(:discount, discount_percent: 10, item_threshold: 6)
      @discount_2.items << @megan.items

      expect(@cart.highest_discount(@giant).first).to eq(@discount_2)

      @discount_3 = create(:discount, discount_percent: 15, item_threshold: 2)
      @discount_3.items << @megan.items

      expect(@cart.highest_discount(@giant).first).to eq(@discount_3)
    end

  end
end
