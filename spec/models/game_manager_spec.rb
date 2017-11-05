require 'rails_helper'

RSpec.describe GameManager, type: :model do
  let!(:game) { create(:game, usernames: ['username', 'other_user'].to_json) }
  let(:username) { 'username' }

  def add_roll(score)
    GameManager.add_roll({ 'game_id' => game.id, 'score' => score, 'username' => username })
  end

  def add_rolls(scores)
    scores.each { |score| add_roll(score) }
  end

  describe '.add_roll' do
    context 'when roll params are valid' do
      it 'returns a roll' do
        expect(add_roll(5).score).to eq(5)
      end
    end

    context 'when username is no valid' do
      it 'returns status code 422' do
        expect {
          GameManager.add_roll({ 'game_id' => game.id, 'score' => 5, 'username' => 'invalid username' })
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when roll score is greater than 10' do
      it 'raises RecordInvalid exception' do
        expect { add_roll(15) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when roll score is smaller than 0' do
      it 'raises RecordInvalid exception' do
        expect { add_roll(-4) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when total frame pins is greater than 10' do
      it 'raises RecordInvalid exception' do
        expect {
          add_roll(5)
          add_roll(7)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when the total number of rolls is greater than 21' do
      it 'raises RecordInvalid exception' do
        expect {
          22.times { add_roll(0) }
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when the total number of rolls is 21 and the last frame is not strive nor spare' do
      it 'raises RecordInvalid exception' do
        expect {
          20.times { add_roll(0) }
          add_roll(4)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when the total number of rolls is 21 and the last frame is strive' do
      it 'does not raise RecordInvalid exception' do
        expect {
          18.times { add_roll(0) }
          add_rolls([10, 6, 7])
        }.to_not raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when the total number of rolls is 21 and the last frame is spare' do
      it 'does not raise RecordInvalid exception' do
        expect {
          18.times { add_roll(0) }
          add_rolls([4, 6, 7])
        }.to_not raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when there are 13 strives' do
      it 'raises RecordInvalid exception' do
        expect {
          13.times { add_roll(10) }
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe '.compute_results' do
    let(:results) { GameManager.compute_results(game) }
    let(:result) { results.first }
    let(:frames) { result[:frames] }
    let(:frame) { frames.first }
    let(:rolls) { frame[:rolls] }
    let(:roll) { rolls.first }

    context 'when there is no roll' do
      it 'returns empty result' do
        expect(results).to be_empty()
      end
    end

    context 'when there is one roll' do
      before { add_roll(6) }

      it 'returns one result' do
        expect(results.size).to eq(1)
        expect(result[:username]).to eq(username)
        expect(result[:score]).to eq(6)
      end

      it 'returns one result containing one frame with one roll' do
        expect(rolls.size).to eq(1)
        expect(roll.score).to eq(6)
      end

      it 'computes frame score' do
        expect(frame[:score]).to eq(6)
      end
    end

    context 'when there is two rolls' do
      before { add_rolls([3, 5]) }

      it 'returns one result containing one frame with two roll' do
        expect(frames.size).to eq(1)
        expect(rolls.size).to eq(2)
        expect(rolls.first.score).to eq(3)
        expect(rolls.last.score).to eq(5)
      end

      it 'computes frame score' do
        expect(frame[:score]).to eq(8)
      end
    end

    context 'when there is a strive' do
      before { add_rolls([10, 3, 5]) }

      it 'returns one result containing two frames' do
        expect(frames.size).to eq(2)
      end

      it 'returns one result in which the first frame is strive' do
        expect(rolls.size).to eq(1)
        expect(frame[:score]).to eq(18)
      end

      it 'returns one result in which the second frame is open frame' do
        expect(frames.last[:rolls].size).to eq(2)
        expect(frames.last[:score]).to eq(8)
      end
    end

    context 'when there are many strives' do
      before  do
        6.times { add_roll(10) }
      end

      it 'returns one result containing 6 frames' do
        expect(frames.size).to eq(6)
      end
    end

    context 'when there is a spare' do
      before { add_rolls([3, 7, 4, 5]) }

      it 'returns one result containing two frames' do
        expect(frames.size).to eq(2)
      end

      it 'returns one result in which the first frame is spare' do
        expect(rolls.size).to eq(2)
        expect(frame[:score]).to eq(14)
      end
    end

    context 'when the last frame is strive' do
      before {
        18.times.each { add_roll(0) }
        add_rolls([10, 5, 9])
      }

      it 'returns one result with 10 frames' do
        expect(frames.size).to eq(10)
      end

      it 'returns one result with the last frame has an extra roll' do
        expect(frames.last[:rolls].size).to eq(3)
        expect(frames.last[:score]).to eq(24)
      end
    end

    context 'when the last frame is spare' do
      before {
        18.times.each { add_roll(0) }
        add_rolls([5, 5, 9])
      }

      it 'returns one result with 10 frames' do
        expect(frames.size).to eq(10)
      end

      it 'returns one result with the last frame has an extra roll' do
        expect(frames.last[:rolls].size).to eq(3)
        expect(frames.last[:score]).to eq(19)
      end
    end

    context 'when all rolls are strive' do
      before do
        12.times { add_roll(10) }
      end

      it 'returns 300 score' do
        expect(result[:score]).to eq(300)
      end
    end

    context 'when all rolls miss' do
      before do
        12.times { add_roll(0) }
      end

      it 'returns 0 score' do
        expect(result[:score]).to eq(0)
      end
    end

    context 'when rolls are randomized' do
      before do
        add_rolls([10, 3, 7, 6, 1, 10, 10, 10, 2, 8, 9, 0, 7, 3, 10, 10, 10])
      end

      it 'returns 193 score' do
        expect(result[:score]).to eq(193)
      end
    end

    context 'when there are two players' do
      before {
        add_roll(1)
        GameManager.add_roll({ 'game_id' => game.id, 'score' => 4, 'username' => 'other_user' })
      }

      it 'returns two results' do
        expect(results.size).to eq(2)
      end
    end
  end
end
