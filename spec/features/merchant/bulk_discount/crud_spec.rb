require 'rails_helper'

RSpec.describe "As a merchant employee" do
  describe "when I log in to my account and go to the dashboard" do

    it "I see a section with all Bulk Discounts I have created" do

    end

    it "I see a link to create a new discount" do

    end

    it "Next to each discount, there is an edit button" do

    end

    it "next to each discount, there is a delete button" do

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

      end

      it "with incorrectly filled fields I still see the new discount form with an error flash message" do

      end

    end
  end


  describe "when I click a link to 'Edit Discount'" do
    it "I am taken to a prefilled bulk discount edit form" do

    end

    describe "when I click 'Update Discount'" do
      it "with completed fields, I am returned to the merchant dashboard where I see the updated discount and a success flash message" do

      end

      it "with one or more missing fields, I still see the edit form with an error flash message" do

      end
    end
  end

  describe "when I click a link to 'Delete Discount'" do
    it "I am redirected to the merchant dashboard, I no longer see the discount, and I see a flash success message" do

    end
  end
end
