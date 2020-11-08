require 'rails_helper'

RSpec.describe "As a user" do
  describe "when I add enough items into my cart to cross the discount threshold" do
    before :each do
      user = create(:user)
      merchant = create(:merchant, :with_items, item_count: 3)
      @item_1 = merchant.items[0]
      @item_2 = merchant.items[1]
      @item_3 = merchant.items[2]
      @items = [@item_1, @item_2, @item_3]
      @discount = create(:discount, discount_percent: 10, item_threshold: 5)
      @discount.items << @items
      @item_1_price = @item_1.price
      @item_2_price = @item_2.price
      @item_3_price = @item_3.price

      visit login_path
      fill_in :email, with: user.email
      fill_in :password, with: 'password'
      click_button 'Login'

      visit item_path(@item_1)
      click_button "Add To Cart"

      visit cart_path
      within "#cart-item-#{@item_1.id}" do
        click_button "+"
        click_button "+"
        click_button "+"
      end
    end

    it "the discount will apply automatically" do
      expected_price = '$' + '%.2f' % (@item_1_price * 4).round(2)
      expected_discount = '$' + '%.2f' % ((@item_1_price * 5) - (@item_1_price * 5 * 0.1)).round(2)

      within "#subtotal-#{@item_1.id}" do
        expect(page).to have_content(expected_price)
      end

      within "#cart-item-#{@item_1.id}" do
        click_button "+"
      end

      within "#subtotal-#{@item_1.id}" do
        expect(page).to have_content(expected_discount)
        expect(page).to have_content("with applied bulk discount")
      end
    end

    it 'the discount will apply only to items that reach the threshold' do
      within "#cart-item-#{@item_1.id}" do
        click_button "+"
      end

      visit item_path(@item_2)
      click_button "Add To Cart"

      visit cart_path

      item_1_discount = '$' + '%.2f' % ((@item_1_price * 5) - (@item_1_price * 5 * 0.1)).round(2)
      item_2_subtotal = '$' + '%.2f' % @item_2_price.round(2)
      item_2_discount = '$' + '%.2f' % ((@item_2_price * 5) - (@item_2_price * 5 * 0.1)).round(2)

      within "#cart-item-#{@item_1.id}" do
        expect(page).to have_content(item_1_discount)
        expect(page).to have_content("with applied bulk discount")
      end

      within "#cart-item-#{@item_2.id}" do
        expect(page).to have_content(item_2_subtotal)
      end

      within "#cart-item-#{@item_2.id}" do
        click_button "+"
        click_button "+"
        click_button "+"
        click_button "+"
      end

      within "#cart-item-#{@item_2.id}" do
        expect(page).to have_content(item_2_discount)
      end
    end

    it 'will apply the highest discount' do
      @discount_2 = create(:discount, discount_percent: 15, item_threshold: 5)
      @discount_2.items << @items

      within "#cart-item-#{@item_1.id}" do
        click_button "+"
      end

      item_1_discount_1 = '$' + '%.2f' % ((@item_1_price * 5) - (@item_1_price * 5 * 0.1)).round(2)
      item_1_discount_2 = '$' + '%.2f' % ((@item_1_price * 5) - (@item_1_price * 5 * 0.15)).round(2)

      within "#cart-item-#{@item_1.id}" do
        expect(page).to have_content(item_1_discount_2)
        expect(page).to_not have_content(item_1_discount_1)
      end
    end

    it 'discount will not apply to other merchant items' do
      merchant_2 = create(:merchant, :with_items, item_count: 1)
      item_4 = merchant_2.items[0]

      visit item_path(item_4)
      click_button "Add To Cart"

      visit cart_path

      within "#cart-item-#{item_4.id}" do
        click_button "+"
        click_button "+"
        click_button "+"
        click_button "+"
        click_button "+"
      end

      item_4_subtotal = '$' + '%.2f' % ((item_4.price * 6).round(2))

      within "#cart-item-#{item_4.id}" do
        expect(page).to have_content(item_4_subtotal)
      end
    end

    it 'discount will be reflected in the price coloumn' do
      discounted_price = '$' + '%.2f' % ((@item_1.price) - (@item_1.price * 0.1))
      within "#cart-item-#{@item_1.id}" do
        click_button "+"
      end

      within ".price" do
        expect(page).to have_content(discounted_price)
      end
    end

    it 'the subtotal will reflect discounted prices' do
      total_price = ('$' + '%.2f' % (((@item_1.price) - (@item_1.price * 0.1)) * 5))

      within "#cart-item-#{@item_1.id}" do
        click_button "+"
      end

      within ".total" do
        expect(page).to have_content(total_price)
      end
    end

  end
end
