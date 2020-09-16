# frozen_string_literal: true

class CartAddOperator
  attr_reader :game_id, :stock_id, :quantity, :cart_user_id

  def initialize(game_id: nil, stock_id: nil, quantity: 1, cart_user_id:)
    @game_id = game_id
    @stock_id = stock_id
    @quantity = quantity
    @cart_user_id = cart_user_id
  end

  def perform
    raise InvalidInput unless valid_input?

    @stock_id = best_available_stock.id if add_from_game?

    cart.add_item(stock_id, quantity)
  end

  private

  def valid_input?
    game_id || stock_id
  end

  def game
    @game ||= Game.find(game_id)
  end

  def cart
    Cart.new(cart_user_id)
  end

  def best_available_stock
    @best_stock ||= game.best_available_stock(cart_user_id) # will be nil if no stock

    raise NoStockExistError unless @best_stock

    @best_stock
  end

  def add_from_game?
    game_id && stock_id.nil?
  end

  class NoStockExistError < StandardError; end
  class InvalidInput < StandardError; end
end
