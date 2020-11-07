require 'rails_helper'

RSpec.describe "As a merchant employee" do
  describe "when I log in to my account and go to the dashboard" do
    before :each do
      visit login_path
      merchant = create(:merchant)
      merchant_employee = create(:user, role: 1, merchant: merchant)
      item_1 = create(:item, merchant: merchant)
      item_2 = create(:item, merchant: merchant)
      item_3 = create(:item, merchant: merchant)

      @discount = create(:discount)
      @discount_2 = create(:discount)
      items = [item_1, item_2, item_3]
      @discount.items << items
      @discount_2.items << items

      fill_in :email, with: merchant_employee.email
      fill_in :password, with: 'password'
      click_button 'Login'
    end

    it "I see a section with all Bulk Discounts I have created" do
      within '.bulk-discounts' do
        expect(page).to have_css(".discount", count:2)
        expect(page).to have_content(@discount.discount_percent)
        expect(page).to have_content(@discount.item_threshold)
        expect(page).to have_content(@discount_2.discount_percent)
        expect(page).to have_content(@discount_2.item_threshold)
      end
    end

    it "I see a link to create a new discount" do
      within '.bulk-discounts' do
        click_link 'Create New Bulk Discount'
      end
    end

    it "Next to each discount, there is an edit button" do
      within "#discount-#{@discount.id}" do
        expect(page).to have_link("Edit Discount")
      end
    end

    it "next to each discount, there is a delete button" do
      within "#discount-#{@discount.id}" do
        expect(page).to have_link("Delete Discount")
      end
    end
  end

  describe "when I can click the link to 'Create New Bulk Discount'" do
    before :each do
      visit login_path
      merchant = create(:merchant)
      merchant_employee = create(:user, role: 1, merchant: merchant)
      item_1 = create(:item, merchant: merchant)
      item_2 = create(:item, merchant: merchant)
      item_3 = create(:item, merchant: merchant)

      fill_in :email, with: merchant_employee.email
      fill_in :password, with: 'password'
      click_button 'Login'

      within '.bulk-discounts' do
        click_link 'Create New Bulk Discount'
      end
    end

    it "I see a form to create a new discount and item threshold" do
      expect(current_path).to eq("/merchant/discounts/new")
      expect(find_field("discount[discount_percent]").value).to eq(nil)
      expect(find_field("discount[item_threshold]").value).to eq(nil)
      expect(page).to have_button("Create Bulk Discount")
    end

    describe "when I click 'Create Bulk Discount' within a new bulk discount form" do
      it "with all form fields completed, I am redirected to my merchant dashboard where I see the discount and a success flash message" do
        percent = 5
        threshold = 10
        fill_in "discount[discount_percent]", with: percent
        fill_in "discount[item_threshold]", with: threshold

        click_button "Create Bulk Discount"

        expect(current_path).to eq(merchant_root_path)
        expect(page).to have_content("You have succesfully created a bulk discount")

        discount = Discount.last

        within "#discount-#{discount.id}" do
          expect(page).to have_content("#{percent}% Discount")
          expect(page).to have_content("Item threshold: #{threshold} items")
        end
      end

      it "with one or more missing fields, I still see the new discount form with an error flash message" do
        percent = 5
        threshold = 10
        fill_in "discount[discount_percent]", with: percent

        click_button "Create Bulk Discount"

        expect(find_field("discount[discount_percent]").value).to eq(percent.to_s)
        expect(find_field("discount[item_threshold]").value).to eq("")
        expect(page).to have_content("Item threshold can't be blank")

        fill_in "discount[discount_percent]", with: ""
        fill_in "discount[item_threshold]", with: threshold

        click_button "Create Bulk Discount"

        expect(find_field("discount[discount_percent]").value).to eq("")
        expect(find_field("discount[item_threshold]").value).to eq(threshold.to_s)
        expect(page).to have_content("Discount percent can't be blank")
      end

      it "with incorrectly filled fields I still see the new discount form with an error flash message" do
        percent = "five"
        threshold = "ten"
        fill_in "discount[discount_percent]", with: percent
        fill_in "discount[item_threshold]", with: threshold

        click_button "Create Bulk Discount"

        expect(page).to have_content("Discount percent is not a number and Item threshold is not a number")
      end
    end
  end

  describe "when I click a link to 'Edit Discount'" do
    before :each do
      visit login_path
      merchant = create(:merchant)
      merchant_employee = create(:user, role: 1, merchant: merchant)
      item_1 = create(:item, merchant: merchant)
      item_2 = create(:item, merchant: merchant)
      item_3 = create(:item, merchant: merchant)

      @discount = create(:discount)
      @discount_2 = create(:discount)
      items = [item_1, item_2, item_3]
      @discount.items << items
      @discount_2.items << items

      fill_in :email, with: merchant_employee.email
      fill_in :password, with: 'password'
      click_button 'Login'

      within "#discount-#{@discount.id}" do
        click_link "Edit Discount"
      end
    end

    it "I am taken to a prefilled bulk discount edit form" do
      expect(current_path).to eq("/merchant/discounts/#{@discount.id}/edit")
      expect(find_field("discount[discount_percent]").value).to eq(@discount.discount_percent.to_s)
      expect(find_field("discount[item_threshold]").value).to eq(@discount.item_threshold.to_s)
      expect(page).to have_button("Update Bulk Discount")
    end

    describe "when I click 'Update Discount'" do
      it "with completed fields, I am returned to the merchant dashboard where I see the updated discount and a success flash message" do
        percent_update = 20
        fill_in "discount[discount_percent]", with: percent_update
        click_button "Update Bulk Discount"
        expect(page).to have_content("Bulk discount successfully updated")
        within "#discount-#{@discount.id}" do
          expect(page).to have_content("#{percent_update}% Discount")
        end
      end

      it "with one or more missing fields, I still see the edit form with an error flash message" do
        percent_update = ""
        threshold_update = ""

        fill_in "discount[discount_percent]", with: percent_update
        click_button "Update Bulk Discount"

        expect(page).to have_content("Discount percent can't be blank")
        expect(find_field("discount[discount_percent]").value).to eq(@discount.discount_percent.to_s)
        expect(find_field("discount[item_threshold]").value).to eq(@discount.item_threshold.to_s)

        fill_in "discount[item_threshold]", with: threshold_update
        click_button "Update Bulk Discount"
        expect(page).to have_content("Item threshold can't be blank")
        expect(find_field("discount[discount_percent]").value).to eq(@discount.discount_percent.to_s)
        expect(find_field("discount[item_threshold]").value).to eq(@discount.item_threshold.to_s)
      end
    end
  end

  describe "when I click a link to 'Delete Discount'" do
    it "I am redirected to the merchant dashboard, I no longer see the discount, and I see a flash success message" do
      visit login_path
      merchant = create(:merchant)
      merchant_employee = create(:user, role: 1, merchant: merchant)
      item_1 = create(:item, merchant: merchant)
      item_2 = create(:item, merchant: merchant)
      item_3 = create(:item, merchant: merchant)

      @discount = create(:discount)
      @discount_2 = create(:discount)
      items = [item_1, item_2, item_3]
      @discount.items << items
      @discount_2.items << items

      fill_in :email, with: merchant_employee.email
      fill_in :password, with: 'password'
      click_button 'Login'

      within "#discount-#{@discount.id}" do
        click_link "Delete Discount"
      end

      expect(current_path).to eq(merchant_root_path)
      expect(page).to have_content("Discount successfully deleted")
      
      within ".bulk-discounts" do
        expect(page).to_not have_css("#discount-#{@discount.id}")
        expect(page).to have_css("#discount-#{@discount_2.id}")
      end
    end
  end
end
