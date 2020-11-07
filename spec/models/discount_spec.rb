require 'rails_helper'

RSpec.describe Discount, type: :model do
  describe 'validations' do
    it {should validate_presence_of :discount_percent}
    it {should validate_presence_of :item_threshold}
    it {should validate_numericality_of(:discount_percent).is_greater_than(0)}
    it {should validate_numericality_of(:discount_percent).is_less_than_or_equal_to(100)}
    it {should validate_numericality_of(:item_threshold).is_greater_than(0)}
    it {should validate_numericality_of(:item_threshold).is_less_than_or_equal_to(100)}
  end

  describe 'relationships' do
    it {should have_many :item_discounts}
    it {should have_many(:items).through(:item_discounts)}
  end

  describe 'instance methods' do
    describe '#apply_to_all_merchant_items()' do
      it "creates an item association for all merchant items" do
        merchant = create(:merchant)
        merchant_employee = create(:user, role: 1, merchant: merchant)
        item_1 = create(:item, merchant: merchant)
        item_2 = create(:item, merchant: merchant)
        item_3 = create(:item, merchant: merchant)
        discount = create(:discount)

        discount.apply_to_all_merchant_items(merchant.id)
        merchant.reload

        items = [item_1, item_2, item_3]

        expect(discount.items).to eq(items)
      end

      it "creates an association with only one merchant's items" do
        merchant = create(:merchant)
        merchant_2 = create(:merchant)
        merchant_employee = create(:user, role: 1, merchant: merchant)
        item_1 = create(:item, merchant: merchant)
        item_2 = create(:item, merchant: merchant)
        item_3 = create(:item, merchant: merchant_2)
        discount = create(:discount)

        discount.apply_to_all_merchant_items(merchant_2.id)
        merchant_2.reload

        items = [item_3]

        expect(discount.items).to eq(items)
      end
    end
  end
end
