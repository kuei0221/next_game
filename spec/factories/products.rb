# frozen_string_literal: true

FactoryBot.define do
  factory :product, class: Product do
    association :game, strategy: :create
    association :user, strategy: :create
    price { 500 }
    quantity { 1 }
    state { 0 }

    trait :pending do
      state { 0 }
    end

    trait :selling do
      state { 1 }
    end

    factory :stock, class: Stock do
      type { 'Stock' }
    end

    factory :order_item, class: OrderItem do
      type { 'OrderItem' }
    end
  end
end
