# frozen_string_literal: true

class Cart
  include ActiveModel::Model
  include Redis::Objects
  include Draper::Decoratable
  include CanGatherError

  redis_id_field :user_id
  set :items

  attr_accessor :user_id

  def initialize(user_id)
    @user_id = user_id
  end

  def cart_items
    @cart_items ||= items.map do |stock_id|
      CartItem.new(user_id, stock_id)
    end
  end

  def add_item(stock_id, quantity)
    item = CartItem.new(user_id, stock_id)
    return false unless child_valid?(item)

    if items.member?(stock_id.to_s)
      item.increment(quantity)
    else
      item.quantity = quantity
      items << stock_id
    end
  end

  def change_item(stock_id, quantity)
    item = CartItem.new(user_id, stock_id)
    return false unless child_valid?(item)

    if items.member?(stock_id.to_s)
      item.quantity = quantity
    end
  end

  def remove_item(stock_id)
    item = CartItem.new(user_id, stock_id)
    return false unless child_valid?(item)

    if items.member?(stock_id.to_s)
      items.delete(stock_id.to_s) && item.clear
    end
  end

  def total_price
    items.present? ? cart_items.sum(&:total_price) : 0
  end

  def clear!
    cart_items.all?(&:clear) && items.clear
  end

  def checkout!
    cart_items.reject(&:checkout).each { |item| gather_error!(item) }

    raise CheckoutError if errors.any?
  end

  class CheckoutError < StandardError; end
end

