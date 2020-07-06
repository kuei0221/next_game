# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    name { 'Game' }
    price { 1900 }
    association :platform, factory: :platform, strategy: :create
  end
end
