class Roll < ApplicationRecord
  belongs_to :game
  validates_presence_of :username, :score
  validates :score, numericality: { less_than_or_equal_to: 10, greater_than_or_equal_to: 0 }
end
