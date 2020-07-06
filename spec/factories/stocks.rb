FactoryBot.define do
  factory :stock do
    association :game, strategy: :create
    association :user, strategy: :create
    price { 500 }
    quantity { 1 }
    state { 0 }
  end
end
