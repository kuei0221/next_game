# frozen_string_literal: true

class CartItem
  include ActiveModel::Model
  include ActiveModel::Validations
  include Redis::Objects
  include Draper::Decoratable
  
  counter :price
  counter :quantity
  value :detail
  
  validates :detail, presence: true
  validate :quantity_should_be_positive
  validate :stock_should_be_latest, on: :checkout
  
  attr_reader :id, :stock_id
  
  def initialize(cart_id, stock_id)
    @stock_id = stock_id
    @id = "#{cart_id}:#{stock_id}"
    
    if self.detail.nil?
      self.detail = detail_json
      self.price.value = stock.price
    end
  end

  def quantity=(value)
    if stock.quantity < value.to_i || value.to_i.negative?
      raise InvalidQuantity
    end

    self.quantity.value = value
  end

  def increment(value)
    if value.to_i.negative?
      raise InvalidQuantity
    end

    self.quantity += value.to_i
  end

  def total_price
    quantity.value * price.value
  end

  def stock
    @stock ||= Stock.find_by(id: stock_id)
  end

  def clear
    redis_delete_objects
  end

  def latest?
    stock.price == price.value && stock.quantity >= quantity.value
  end

  def checkout
    return false unless valid?(:checkout)

    stock.reduce_quantity!(quantity.value)
  end


  private

  def detail_json
    {
      game_id: stock.game_id,
      game_name: stock.game_name,
      owner_email: stock.user.email,
      owner_id: stock.user.id,
      stock_quantity: stock.quantity
    }.to_json
  end

  def stock_should_be_latest
    return true if stock && latest?

    errors.add(:stock, 'is outdated')
    false
  rescue ActiveRecord::RecordNotFound => e
    errors.add(:stock, 'record has removed')
    false
  end

  def quantity_should_be_positive
    return true unless quantity.value.negative?

    errors.add(:quantity, 'cannot be negative')
    false
  end

  class InvalidQuantity < StandardError; end
end
