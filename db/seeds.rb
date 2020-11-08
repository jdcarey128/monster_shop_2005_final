# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

ItemOrder.destroy_all
ItemDiscount.destroy_all
Order.destroy_all
User.destroy_all
Merchant.destroy_all
Discount.destroy_all
Item.destroy_all

#users
user_1 = User.create!(name: "James Purfield", street_address: "123 fake st", city: "Aurora", state: "CO", zip: 80017, email: "jamesp@gmail.com", password: "password", password_confirmation: "password")
user_2 = User.create!(name: "Lilly Potter", street_address: "123 downer's grove", city: "Aurora", state: "CO", zip: 80017, email: "fake.gmail@gmail.com", password: "password1", password_confirmation: "password1")
user_3 = User.create!(name: "Admin person", street_address: "123 downer's grove", city: "Aurora", state: "CO", zip: 80017, email: "admin@example.com", password: "admin", password_confirmation: "admin", role: 2)

#merchants
bike_shop = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
dog_shop = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)
bagel_and_deli = Merchant.create(name: "Bagel and Deli", address: '125 High st.', city: 'Oxford', state: 'OH', zip: 45506)

user_4 = User.create!(name: "Molly Merchant", street_address: "123 downer's grove", city: "Aurora", state: "CO", zip: 80017, email: "merchant@example.com", password: "merchant", password_confirmation: "merchant", role: 1, merchant_id: bike_shop.id)

#bike_shop items
tire = bike_shop.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
bike = bike_shop.items.create(name: "Mountain Bike", description: "An amazing bike!", price: 2100, image: "https://www.bigandtallbike.com/assets/images/BIG%20six%20S%20tube%20gray%20ISO%202400px.png", inventory: 2)
brakes = bike_shop.items.create(name: "Brakes", description: "Outstanding brakes!", price: 200, image: "https://content.backcountry.com/images/items/900/SHI/SHIU18H/BLA.jpg", inventory: 8)
frame = bike_shop.items.create(name: "Frame", description: "You'll love thif frame!", price: 1000, image: "https://content.backcountry.com/images/items/900/SNZ/SNZK145/HIGBLU.jpg", inventory: 4)
helmet = bike_shop.items.create(name: "Helmet", description: "Protect you head!", price: 150, image: "https://www.rei.com/media/f16a435f-6235-476d-85df-83115eb0ea8f?size=784x588", inventory: 10)

#dog_shop items
pull_toy = dog_shop.items.create(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)
dog_bone = dog_shop.items.create(name: "Dog Bone", description: "They'll love it!", price: 21, image: "https://img.chewy.com/is/image/catalog/54226_MAIN._AC_SL1500_V1534449573_.jpg", active?:false, inventory: 21)
frisbee = dog_shop.items.create(name: "Frisbee", description: "You can't beat the classics!", price: 12, image: "https://img.chewy.com/is/image/catalog/59178_MAIN._AC_SL1500_V1518037644_.jpg", inventory: 14)
tennis_balls = dog_shop.items.create(name: "Tennis Balls", description: "Dogs love tennis balls!", price: 4, image: "https://www.tennisexpress.com/prodimages/45486-DEFAULT-l.jpg", inventory: 24)
rope_ball = dog_shop.items.create(name: "Rope Ball", description: "Long lasting!", price: 6, image: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTwfiN0gFv8L9fNBhqq-gJck51PZqIlTOifLw&usqp=CAU", inventory: 12)

#bagel_and_deli items
bagel = bagel_and_deli.items.create(name: "Kosher Bagels", description: "Boiled and dense", price: 10, image: "https://www.tennisexpress.com/prodimages/45486-DEFAULT-l.jpg", inventory: 30)
steamer = bagel_and_deli.items.create(name: "Sandwich Steamer", description: "Can fit 3 bagel sandwiches", price: 1000, image: "https://www.tennisexpress.com/prodimages/45486-DEFAULT-l.jpg", inventory: 10)

#orders
order_1 = Order.create!(name: user_1.name, address: user_1.street_address, city: user_1.city, state: user_1.state, zip: user_1.zip, status: 2, user_id: user_1.id)
order_2 = Order.create!(name: user_1.name, address: user_1.street_address, city: user_1.city, state: user_1.state, zip: user_1.zip, status: 2, user_id: user_1.id)
order_3 = Order.create!(name: user_1.name, address: user_1.street_address, city: user_1.city, state: user_1.state, zip: user_1.zip, status: 2, user_id: user_1.id)
order_4 = Order.create!(name: user_2.name, address: user_2.street_address, city: user_2.city, state: user_2.state, zip: user_2.zip, status: 2, user_id: user_2.id)
order_5 = Order.create!(name: user_2.name, address: user_2.street_address, city: user_2.city, state: user_2.state, zip: user_2.zip, status: 2, user_id: user_2.id)

#item_orders
item_order_1 = ItemOrder.create!(order_id: order_1.id, item_id: pull_toy.id, price: pull_toy.price, quantity: 5)
item_order_2 = ItemOrder.create!(order_id: order_2.id, item_id: brakes.id, price: brakes.price, quantity: 4)
item_order_3 = ItemOrder.create!(order_id: order_3.id, item_id: tire.id, price: tire.price, quantity: 3)
item_order_4 = ItemOrder.create!(order_id: order_4.id, item_id: rope_ball.id, price: pull_toy.price, quantity: 10)
item_order_5 = ItemOrder.create!(order_id: order_5.id, item_id: tennis_balls.id, price: pull_toy.price, quantity: 16)
item_order_6 = ItemOrder.create!(order_id: order_5.id, item_id: bagel.id, price: bagel.price, quantity: 6)
item_order_7 = ItemOrder.create!(order_id: order_1.id, item_id: steamer.id, price: steamer.price, quantity: 8)
item_order_8 = ItemOrder.create!(order_id: order_3.id, item_id: helmet.id, price: helmet.price, quantity: 7)
item_order_9 = ItemOrder.create!(order_id: order_4.id, item_id: frisbee.id, price: frisbee.price, quantity: 20)
item_order_10 = ItemOrder.create!(order_id: order_1.id, item_id: frame.id, price: frame.price, quantity: 2)
item_order_11 = ItemOrder.create!(order_id: order_2.id, item_id: dog_bone.id, price: dog_bone.price, quantity: 14)
