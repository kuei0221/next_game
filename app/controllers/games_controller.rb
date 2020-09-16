# frozen_string_literal: true

class GamesController < ApplicationController
  include HasCart

  def show
    @game = Game.includes(stocks: :user).find_by(id: params[:id])
    return if @game

    flash.alert = 'Game Not Found'
    redirect_to games_path
  end

  def index
    @games = Game.all

    @games = @games.search_by_name(game_params[:name]) if game_params[:name]

    @games = @games.search_by_platform(game_params[:platform]) if game_params[:platform]

    @games = @games.with_attached_cover.includes(:platform, :stocks)
  end

  private

  def game_params
    params.permit(:name, :platform, :commit)
  end
end
