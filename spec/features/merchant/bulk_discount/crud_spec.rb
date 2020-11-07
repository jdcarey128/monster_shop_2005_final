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
    it "and I see a form to create a new discount and item threshold" do
    end

    describe "when I click 'Create Bulk Discount' within a new bulk discount form" do
      it "with all form fields completed, I am redirected to my merchant dashboard where I see the discount and a success flash message" do

      end

      it "with one or more missing fields, I still see the new discount form with an error flash message" do

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
