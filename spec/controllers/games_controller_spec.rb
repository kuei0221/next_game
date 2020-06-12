# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  describe '#index' do
    subject { assigns[:games] }

    let!(:platforms) do
      [
        create(:platform, id: 1, name: 'PS4'),
        create(:platform, id: 2, name: 'NS')
      ]
    end

    let!(:games) do
      [
        create(:game, name: 'Dark Soul 2', platform_id: 1),
        create(:game, name: 'Dark Soul 3', platform_id: 1),
        create(:game, name: 'Splatoon', platform_id: 2),
        create(:game, name: 'Super Mario 8', platform_id: 2)
      ]
    end

    context 'without any query' do
      it 'show all games' do
        get :index
        expect(subject).to match(games)
      end
    end

    context 'query with name' do
      it 'should find game with given name' do
        get :index, params: { name: 'dark' }
        expect(subject).to include(games[0], games[1])
      end
    end

    context 'query with platform' do
      it 'should filter game with give platform' do
        get :index, params: { platform: 2 }
        expect(subject).to include(games[2], games[3])
      end
    end

    context 'query with both name and platform' do
      it 'should find game match both requirement' do
        get :index, params: { name: 'ar', platform: 2 }
        expect(subject).to include games[3]
      end
    end
  end
end
