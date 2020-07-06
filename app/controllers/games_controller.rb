# frozen_string_literal: true

class GamesController < ApplicationController

  def show
    @game = Game.includes(stocks: :user).find_by(id: params[:id])
    unless @game
      flash.alert = 'Game not Found'
      redirect_to games_path
    end
  end

  def index
    @games = Game.all

    if game_params[:name]
      @games = @games.search_by_name(game_params[:name])
    end

    if game_params[:platform]
      @games = @games.search_by_platform(game_params[:platform])
    end

    @games = @games.with_attached_cover.includes(:platform, :stocks)
  end

  private

  def game_params
    params.permit(:name, :platform, :commit)
  end
end
