# frozen_string_literal: true

class Order < ApplicationRecord
  has_many :items, class_name: 'OrderItem', foreign_key: :order_uuid, inverse_of: :order
  belongs_to :buyer, class_name: "User", foreign_key: "buyer_id"

  attribute :uuid, :string, default: -> { SecureRandom.uuid }
end
