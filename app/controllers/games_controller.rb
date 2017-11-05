class GamesController < ApplicationController
  before_action :set_game, only: [:show, :update, :destroy]

  def index
    @games = Game.all.map { |game| game_response(game) }
    json_response(@games)
  end

  def show
    json_response(game_response(@game))
  end

  def create
    @game = Game.create!(game_params)
    json_response(game_response(@game), :created)
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
    {
      name: params[:name],
      usernames: (params[:usernames] || []).to_json
    }
  end

  def game_response(game)
    {
      id: game.id,
      name: game.name,
      usernames: game.usernames,
      results: GameManager.compute_results(game)
    }
  end

end
