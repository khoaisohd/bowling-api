class GamesController < ApplicationController
  before_action :set_game, only: [:show, :update, :destroy]

  def index
    @games = Game.all
    json_response(@games)
  end

  def show
    json_response(
      id: @game.id,
      name: @game.name,
      results: GameManager.compute_results(@game)
    )
  end

  def create
    @game = Game.create!(game_params)
    json_response(@game, :created)
  end

  def update
    @game.update(game_params)
    head :no_content
  end

  def destroy
    @game.destroy
    head :no_content
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.permit(:name)
  end
end
