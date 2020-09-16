# frozen_string_literal: true

class CartDecorator < ApplicationDecorator
  delegate_all
  decorates_association :cart_items

  def to_order_items
    cart_items.map(&:to_order_item)
  end
end
