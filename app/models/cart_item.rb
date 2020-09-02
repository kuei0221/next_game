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
  validate :cannot_buy_user_own_stock
  validate :stock_should_be_latest
  
  attr_accessor :id, :stock_id, :user_id

  def initialize(user_id, stock_id)
    @user_id = user_id
    @stock_id = stock_id
    @id = "#{user_id}:#{stock_id}"
    
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

  private

  def detail_json
    {
      game_id: stock.game_id,
      game_name: stock.game_name,
      owner_email: stock.user.email,
      stock_quantity: stock.quantity
    }.to_json
  end

  def stock_should_be_latest
    return true if stock.reload && latest?

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

  def cannot_buy_user_own_stock
    return true if stock && stock.user_id != user_id

    errors.add(:user_id, 'cannot buy your own stock !')
    false
  end

  class InvalidQuantity < StandardError; end
end
