class Roll < ApplicationRecord
  belongs_to :game
  validates_presence_of :username, :score
end
