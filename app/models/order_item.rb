# frozen_string_literal: true

class OrderItem < Product
  belongs_to :order, class_name: 'Order', foreign_key: :order_id
  attribute :state, default: :shipping
end
