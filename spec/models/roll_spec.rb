require 'rails_helper'

RSpec.describe Roll, type: :model do
  it { should belong_to(:game) }
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:score) }
end
