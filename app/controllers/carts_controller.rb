# frozen_string_literal: true

class CartsController < ApplicationController
  include HasCart
  before_action :authenticate_user!
  before_action :current_cart

  rescue_from CartItem::InvalidQuantity, with: :invalid_quantity_input

  def add
    if cart_params[:game_id]
      game = Game.find_by(id: cart_params[:game_id])
      stock_id = game.best_available_stock(current_user.id)&.id
      quantity = 1
    elsif cart_params[:stock_id]
      stock_id = cart_params[:stock_id]
      quantity = cart_params[:quantity]
    else
      flash.alert = 'Unrecognized Input, please check it Again'
      redirect_to root_path
    end

    if current_cart.add_item(stock_id, quantity)
      flash.now.notice = 'Add To My Cart!'
    else
      flash.now.alert = 'Fail to add to My Cart'
    end
    respond_to do |format|
      format.js
      format.html { redirect_to root_path }
    end
  end

  def remove
    if current_cart.remove_item(cart_params[:stock_id])
      flash.notice = 'Remove Success'
    else
      flash.alert = 'Remove Fail'
    end
    redirect_to cart_path
  end

  def show; end

  def change
    if current_cart.change_item(cart_params[:stock_id], cart_params[:quantity])
      flash.notice = 'Update Success'
    else
      flash.alert = 'Update Fail'
    end
    redirect_to cart_path
  end

  def checkout
    raise NotImplementedError
  end

  private

  def invalid_quantity_input
    flash.alert = 'Oops! The seller does not have that much stock!'
    redirect_back(fallback_location: root_path)
  end

  def cart_params
    params.permit(:stock_id, :game_id, :quantity)
  end
end
