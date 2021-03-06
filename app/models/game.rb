class Game < ApplicationRecord
  has_many :rolls, -> { order(created_at: :asc) }, dependent: :destroy
  validates_presence_of :name

  def usernames
    JSON.parse(self[:usernames])
  end
end
