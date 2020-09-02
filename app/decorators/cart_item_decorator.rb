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

  def stock_quantity
    detail.fetch('stock_quantity')
  end
end