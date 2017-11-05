require 'rails_helper'

RSpec.describe 'Rolls API' do
  let!(:game) { create(:game) }
  let(:username) { 'username' }
  let!(:rolls) { create_list(:roll, 10, game_id: game.id, username: username, score: 0) }

  let(:game_id) { game.id }
  let(:roll_id) { rolls.first.id }

  describe 'GET /games/:game_id/rolls' do
    before { get "/games/#{game_id}/rolls" }

    context 'when game exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all rolls' do
        expect(json.size).to eq(10)
      end
    end

    context 'when game does not exist' do
      let(:game_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Game/)
      end
    end
  end

  describe 'GET /games/:game_id/rolls/roll_id' do
    before { get "/games/#{game_id}/rolls/#{roll_id}" }

    context 'when roll exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a roll' do
        expect(json['username']).to eq(username)
      end
    end

    context 'when roll does not exist' do
      let(:roll_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Roll/)
      end
    end
  end

  describe 'POST /games/:game_id/rolls' do
    before { post "/games/#{game_id}/rolls", params: params }

    context 'when params are valid' do
      let(:params) { { username: username, score: 5 } }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns a roll' do
        expect(json['username']).to eq(username)
      end
    end

    context 'when params are not valid' do
      let(:params) { { username: username } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(/Validation failed: Score can't be blank/)
      end
    end
  end

  describe 'PUT /games/:game_id/rolls/roll_id' do
    before { put "/games/#{game_id}/rolls/#{roll_id}", params: {} }

    context 'when roll exists' do
      it 'returns status code 202' do
        expect(response).to have_http_status(204)
      end

      it 'returns empty body' do
        expect(response.body).to be_empty
      end
    end

    context 'when roll does not exist' do
      let(:roll_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Roll/)
      end
    end
  end

  describe 'DELETE /games/:game_id/rolls/roll_id' do
    before { delete "/games/#{game_id}/rolls/#{roll_id}" }

    context 'when roll exists' do
      it 'returns status code 202' do
        expect(response).to have_http_status(204)
      end

      it 'returns empty body' do
        expect(response.body).to be_empty
      end
    end

    context 'when roll does not exist' do
      let(:roll_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Roll/)
      end
    end
  end
end
