# frozen_string_literal: true

class CartItem
  include ActiveModel::Model
  include ActiveModel::Validations

  include Redis::Objects
  hash_key :detail
  DETAILS = %i[stock_id game_id game_name owner_email price stock_quantity quantity]
  
  attr_accessor :id, :stock_id, :user_id

  validates :detail, presence: true
  validates :quantity, numericality: { only_integer: true, greather_than: 0 }
  validate :stock_should_exist
  validate :cannot_buy_user_own_stock, if: :stock_should_exist

  def initialize(user_id, stock_id)
    @user_id = user_id
    @stock_id = stock_id
    @id = "#{user_id}:#{stock_id}"

    if detail.empty?
      detail[:stock_id] = stock_id
      detail[:game_id] = stock.game.id
      detail[:game_name] = stock.game_name
      detail[:owner_email] = stock.user.email
      detail[:price] = stock.price
      detail[:stock_quantity] = stock.quantity
    end
  end

  DETAILS.each do |key|
    define_method key do
      key =~ /price|quantity/ ? detail[key].to_i : detail[key]
    end
  end

  def quantity=(value)
    raise InvalidQuantity if stock.quantity < value.to_i

    detail[:quantity] = value.to_i
  end

  def increment(number)
    self.quantity += number.to_i
  end

  def total_price
    quantity * price.to_i
  end

  def stock
    @stock ||= Stock.includes(:game, :user).find_by(id: stock_id)
  end

  def clear
    detail.clear
  end

  private

  def stock_should_exist
    return true if stock

    errors.add(:stock, 'should exist')
    false
  end

  def cannot_buy_user_own_stock
    return true if stock && stock.user.id != user_id

    errors.add(:user_id, 'cannot buy your own stock !')
    false
  end

  class InvalidQuantity < StandardError; end
end
