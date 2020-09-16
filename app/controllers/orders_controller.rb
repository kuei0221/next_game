# frozen_string_literal: true

class OrdersController < ApplicationController
  include HasCart

  before_action :authenticate_user!
  before_action :cart_any_item?

  def new
    @form = OrderForm.new(current_user.id)
  end

  def create
    @form = OrderForm.new(current_user.id)

    if @form.save
      flash.notice = 'Order successfully created'
      redirect_to :root
    else
      flash.now.alert = 'Order cannot create !'
      render 'new'
    end
  end

  private

  def cart_any_item?
    return true if current_cart.items.any?

    flash.alert = 'Your Cart is empty!'
    redirect_to cart_path
  end
end
