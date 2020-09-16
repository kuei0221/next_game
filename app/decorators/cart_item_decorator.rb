# frozen_string_literal: true

class CartItemDecorator < ApplicationDecorator
  delegate_all

  def quantity
    object.quantity.value
  end

  def price
    object.price.value
  end

  def detail
    @detail ||= JSON.parse(object.detail.value)
  end

  def game_id
    detail.fetch('game_id')
  end

  def game_name
    detail.fetch('game_name')
  end

  def owner_email
    detail.fetch('owner_email')
  end

  def owner_id
    detail.fetch('owner_id')
  end

  def stock_quantity
    detail.fetch('stock_quantity')
  end

  def to_order_item
    OrderItem.new(
      game_id: game_id,
      user_id: owner_id,
      price: price,
      quantity: quantity,
      state: 'shipping'
    )
  end

  def errors?
    errors.full_messages.any?
  end

  def outdated
    'This Stock has been refreshed, please remove and add the newer one'
  end
end
