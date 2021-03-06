FactoryBot.define do
  factory :user do
    name { Faker::Superhero.name }
    street_address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip }
    email { Faker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }
  end

  factory :merchant do
    name { Faker::TvShows::HeyArnold.location }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip }

    trait :with_items do
      transient do
        item_count { 3 }
      end

      after(:create) do |merchant, evaluator|
        merchant.items << create_list(:item, evaluator.item_count)
      end
    end

    trait :with_item_orders do
      transient do
        item_count { 3 }
      end

      after(:create) do |merchant, evaluator|
        merchant.items << create_list(:item, evaluator.item_count)
        create(:item_order, item: merchant.items[0])
        create(:item_order, item: merchant.items[1])
        create(:item_order, item: merchant.items[2])
      end
    end
  end

  factory :item do
    sequence(:name) { |n| "Item ##{n}" }
    description { Faker::Lorem.sentence }
    price { rand(1..100)}
    image { 'https://semantic-ui.com/images/wireframe/image.png' }
    inventory { Faker::Number.between(from: 12, to: 34) }

    merchant
  end

  factory :order do
    name { Faker::Name.name }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip }
    user
  end

  factory :item_order do
    item
    order
    order_price { item.price }
    quantity { 1 }
  end

  factory :discount do
    discount_percent { Faker::Number.between(from: 1, to: 100) }
    item_threshold { Faker::Number.between(from: 1, to: 100) }
  end
end
