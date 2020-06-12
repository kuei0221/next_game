# frozen_string_literal: true

class GamesController < ApplicationController
  def show
    @game = Game.find_by(id: params[:id])
  end

  def index
    @games = Game.all

    if game_params[:name]
      @games = @games.search_by_name(game_params[:name])
    end

    if game_params[:platform]
      @games = @games.search_by_platform(game_params[:platform])
    end

    @games = @games.with_attached_cover.includes(:platform)
  end

  private

  def game_params
    params.permit(:name, :platform, :commit)
  end
end
