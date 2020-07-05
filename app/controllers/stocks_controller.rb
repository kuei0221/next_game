# frozen_string_literal: true

class StocksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stocks, except: :show
  before_action :set_stock_form, only: %i[index destroy]

  def create
    @form = StockForm.new(stock_params)
    if @form.save
      flash.now.notice = 'Create Success'
    else
      flash.now.alert = 'Create Fail'
    end
    respond_to do |format|
      format.js
    end
  end

  def update
    @form = StockForm.new(stock_params)
    if @form.save
      flash.now.notice = 'Update Success'
    else
      flash.now.alert = 'Update Fail'
    end

    render :index
  end

  def destroy
    @stock = Stock.find_by(id: params[:id])
    if @stock
      @stock.delete
      flash.now.notice = 'Delete Success'
    else
      flash.now.alert = 'Stock not find'
    end

    render :index
  end

  def index; end

  def show
    redirect_to stocks_path
  end

  private

  def set_stocks
    @stocks = current_user.stocks.includes(:game)
  end

  def set_stock_form
    @form = StockForm.new
  end

  def stock_params
    params.require(:stock).permit(:stock_id, :game_id, :price, :quantity, :state).merge(user_id: current_user.id)
  end
end
