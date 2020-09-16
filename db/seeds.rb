# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'faker'

User.create(
  email: 'michaelhwang0619@gmail.com', password: 'password', confirmed_at: Time.zone.now
)

10.times do
  user = User.create(
    email: Faker::Internet.unique.email, password: 'password', confirmed_at: Time.zone.now
  )
  user.stocks.create(
    game_id: Faker::Number.within(range: 1..4),
    price: Faker::Number.within(range: 500..1500),
    quantity: Faker::Number.within(range: 1..10),
    state: 1
  )
end
