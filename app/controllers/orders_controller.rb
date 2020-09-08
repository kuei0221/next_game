# frozen_string_literal: true

class OrdersController < ApplicationController
  include HasCart
  
  def new
    @form = OrderForm.new(current_user.id)
  end
  
  def create
    @form = OrderForm.new(current_user.id)

    if @form.save
      flash.notice = "Order successfully created"
      redirect_to :root
    else
      flash.now.alert = "Order cannot create !"
      render 'new'
    end
  end

end
