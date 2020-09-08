# frozen_string_literal: true

class OrderItem < Stock
  belongs_to :order, class_name: 'Order', foreign_key: :order_uuid
end
