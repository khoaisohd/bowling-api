require 'rails_helper'

RSpec.describe 'Games API', type: :request do
  let!(:games) { create_list(:game, 10) }
  let!(:game_id) { games.first.id }

  describe 'GET /games' do
    before { get '/games' }

    it 'returns games' do
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET/games/:id' do
    context 'when the game exists' do
      before do
        GameManager.add_roll({ 'game_id' => game_id, 'score' => 4, 'username' => 'username' })
        get "/games/#{game_id}"
      end

      it 'returns the game' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(game_id)
        expect(json['results'].size).to eq(1)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the game does not exist' do
      before { get '/games/100' }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Game/)
      end
    end
  end

  describe 'POST/games' do
    context 'when the request is valid' do
      before { post '/games', params: { name: 'First Game' } }

      it 'returns a game' do
        expect(json['name']).to eq('First Game')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is not valid' do
      before { post '/games', params: {} }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(/Validation failed: Name can't be blank/)
      end
    end
  end

  describe 'PUT/games' do
    context 'when the game exists' do
      before { put "/games/#{game_id}", params: { name: 'Second Game' } }

      it 'returns empty response' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the game does not exist' do
      before { put "/games/100", params: { name: 'Second Game' } }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Game/)
      end
    end
  end

  describe 'DELETE/games' do
    context 'when the game exists' do
      before { delete "/games/#{game_id}" }

      it 'returns empty response' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the game does not exist' do
      before { delete "/games/100" }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Game/)
      end
    end
  end
end
