# frozen_string_literal: true

class Order < ApplicationRecord
  has_many :items, class_name: 'OrderItem', inverse_of: :order, dependent: :destroy
  belongs_to :buyer, class_name: 'User'

  attribute :uuid, :string, default: -> { SecureRandom.uuid }
end
