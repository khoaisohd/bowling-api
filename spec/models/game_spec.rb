require 'rails_helper'

RSpec.describe Game, type: :model do
  it { should have_many(:rolls).dependent(:destroy) }
  it { should validate_presence_of(:name) }
end
