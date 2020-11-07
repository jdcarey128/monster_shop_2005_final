require 'rails_helper'

RSpec.describe Discount, type: :model do
  describe 'validations' do
    it {should validate_presence_of :discount_percent}
    it {should validate_presence_of :item_threshold}
  end

  describe 'relationships' do
    it {should have_many :item_discounts}
    it {should have_many(:items).through(:item_discounts)}
  end
end
