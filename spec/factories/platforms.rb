# frozen_string_literal: true

FactoryBot.define do
  factory :platform do
    sequence(:id)
    name { 'PS4' }

    trait :ps4 do
      id { 1 }
      name { 'PS4' }
    end

    trait :ns do
      id { 2 }
      name { 'NS' }
    end
  end
end
