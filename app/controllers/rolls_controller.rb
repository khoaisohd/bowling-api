class RollsController < ApplicationController
  before_action :set_game
  before_action :set_roll, only: [:show, :update, :destroy]

  def index
    json_response(@game.rolls)
  end

  def show
    json_response(@roll)
  end

  def create
    @roll = GameManager.add_roll(roll_params)
    json_response(@roll, :created)
  end

  def update
    @roll.update(roll_params);
    head :no_content
  end

  def destroy
    @roll.destroy
    head :no_content
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def set_roll
    @roll = Roll.find(params[:id])
  end

  def roll_params
    params.permit(:game_id, :score, :username)
  end
end
