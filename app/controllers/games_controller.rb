class GamesController < ApplicationController
  def index
    @games = Game.all.includes(:platform)
  end

  def show
    @game = Game.find_by(id: params[:id])
  end
end
