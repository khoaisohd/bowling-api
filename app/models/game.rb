class Game < ApplicationRecord
  has_many :rolls, dependent: :destroy
  validates_presence_of :name
end
