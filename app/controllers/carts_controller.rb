# frozen_string_literal: true

class CartsController < ApplicationController
  include HasCart
  
  rescue_from CartItem::InvalidQuantity, with: :invalid_quantity_input
  rescue_from CartAddOperator::NoStockExistError, with: :no_stock_for_game
  rescue_from CartAddOperator::InvalidInput, with: :invalid_params_input

  def add

    params = cart_params.merge(cart_user_id: cart_user_id).to_h.symbolize_keys
    operator = CartAddOperator.new(params)

    if operator.perform
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

  def no_stock_for_game
    flash.alert = 'This Game does not have any Stock yet!'
    redirect_back(fallback_location: root_path)
  end

  def invalid_params_input
    flash.alert = 'You Are Not Buying Anything! Please Make Sure You Are On The Right Page.'
    redirect_back(fallback_location: root_path)
  end

  def cart_params
    params.permit(:stock_id, :game_id, :quantity)
  end
end
