# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "#{n}th_user@email.com" }
    password { 'password' }
  end
end
