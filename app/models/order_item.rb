# frozen_string_literal: true

class OrderItem < Product
  belongs_to :order, class_name: 'Order'
  attribute :state, default: :shipping
end
