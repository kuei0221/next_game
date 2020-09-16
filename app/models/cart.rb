# frozen_string_literal: true

class Cart
  include ActiveModel::Model
  include Redis::Objects
  include Draper::Decoratable
  include CanGatherError

  redis_id_field :user_id
  set :items
  value :uuid

  attr_accessor :user_id

  def initialize(user_id)
    @user_id = user_id

    self.uuid = SecureRandom.uuid if uuid.nil?
  end

  def cart_items
    @cart_items ||= items.map do |stock_id|
      CartItem.new(uuid.value, stock_id)
    end
  end

  def add_item(stock_id, quantity)
    return false unless init_item(stock_id)

    if items.member?(stock_id.to_s)
      @item.increment(quantity)
    else
      @item.quantity = quantity
      items << stock_id
    end
  end

  def change_item(stock_id, quantity)
    return false unless init_item(stock_id)

    @item.quantity = quantity if items.member?(stock_id.to_s)
  end

  def remove_item(stock_id)
    return false unless init_item(stock_id)

    items.delete(stock_id.to_s) && @item.clear if items.member?(stock_id.to_s)
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

  def register!(new_user_id)
    @user_id = new_user_id

    %i[items uuid].all? do |field|
      send(field).rename("cart:#{new_user_id}:#{field}")
    end
  end

  private

  def init_item(stock_id)
    @item = CartItem.new(uuid.value, stock_id)
    child_valid?(@item) ? @item : false
  end

  class CheckoutError < StandardError; end
end
