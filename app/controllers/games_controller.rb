class GamesController < ApplicationController
  def index
    @games = Game.all.includes(:platform)
  end

  def show
    @game = Game.find_by(params[:id])
  end
end
