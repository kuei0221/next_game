# frozen_string_literal: true

class StockForm
  include ActiveModel::Model
  include CanGatherError

  attr_accessor :game_id, :user_id, :price, :quantity, :state, :stock_id

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }, presence: true
  validates :price, numericality: { only_integer: true, greater_than: 0 }, presence: true
  validate :check_game_price, :check_stock
  validate :stock_price_cannot_greater_than_game_price

  def initialize(params = {})
    self.attributes = params
  end

  def attributes=(*args)
    super
    if stock_id
      @stock = Stock.find_by(id: stock_id, user_id: user_id)
      @game_price = @stock&.game_price
      @params = update_params
    elsif game_id
      @stock = Stock.new
      @game_price = Game.find_by(id: game_id)&.price
      @params = create_params
    end
  end

  def save
    return false unless valid?

    @stock.attributes = @params

    child_valid?(@stock) ? @stock.save : false
  end

  private

  def check_stock
    errors.add(:stock, 'cannot be nil') if @stock.nil?
  end

  def check_game_price
    errors.add(:game_price, 'cannot be nil') if @game_price.nil?
  end

  def create_params
    { game_id: game_id, user_id: user_id, price: price, quantity: quantity, state: state }
  end

  def update_params
    { price: price, quantity: quantity, state: state }
  end

  def stock_price_cannot_greater_than_game_price
    return if @game_price && price.to_i <= @game_price

    errors.add(:price, 'cannot greater than game price')
  end
end
