# frozen_string_literal: true

class OrderForm

  include ActiveModel::Model

  attr_accessor :user_id, :cart
  delegate :cart_items, :total_price, to: :cart

  def initialize(user_id)
    @user_id = user_id
    @cart = Cart.new(user_id).decorate
  end

  def save
    ActiveRecord::Base.transaction do
      order = Order.new(
        buyer_id: user_id,
        price: cart.total_price
      )
      lock_stocks
      cart.checkout!
      order.items = cart.cart_items.map(&:to_order_item)
      order.save!
      cart.clear!
    end
  rescue Cart::CheckoutError => e
    errors.add(:cart, e.message)
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:order, e.message)
  ensure
    return errors.blank?
  end

  private

  def lock_stocks
    stock_ids = cart.items.value
    Stock.where(id: stock_ids).lock!
  end
end
