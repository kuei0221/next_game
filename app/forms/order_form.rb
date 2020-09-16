# frozen_string_literal: true

class OrderForm
  include ActiveModel::Model

  attr_accessor :user_id, :cart, :order
  delegate :cart_items, :total_price, to: :cart

  def initialize(user_id)
    @user_id = user_id
    @cart = Cart.new(user_id).decorate
    @order = init_order
  end

  def save
    begin
      ActiveRecord::Base.transaction do
        lock_stocks!
        cart.checkout!
        @order.items = cart.to_order_items
        @order.save!
        cart.clear!
      end
    rescue Cart::CheckoutError => e
      errors.add(:cart, e.message)
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:order, e.message)
    end
    errors.blank?
  end

  private
  
  def init_order
    Order.new(
      buyer_id: user_id,
      price: cart.total_price
    )
  end

  def lock_stocks!
    stock_ids = cart.items.value
    Stock.where(id: stock_ids).lock!
  end
end
