# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  describe '#stocks' do
    subject { game.stocks }
    let!(:game) { create(:game) }
    let!(:stock_1) { create(:stock, :selling, game: game, price: 100, updated_at: 10.days.ago) }
    let!(:stock_2) { create(:stock, :selling, game: game, price: 200, updated_at: 10.days.ago) }
    let!(:stock_3) { create(:stock, :selling, game: game, price: 200, updated_at: 5.days.ago) }
    let!(:stock_4) { create(:stock, :pending, game: game, price: 300, updated_at: 1.day.ago) }
    it 'only show stocks which is selling ' do
      expect(subject).not_to include stock_4
    end
    it 'should order stocks by price asc and updated_at asc' do
      expect(subject.first).to eq stock_1
      expect(subject.second).to eq stock_3
      expect(subject.third).to eq stock_2
    end
  end

  describe '::search_by_name' do
    subject { described_class.search_by_name(name) }
    let!(:platform) { create(:platform) }
    let!(:game_1) { create(:game, platform: platform, name: 'Dark Soul 2') }
    let!(:game_2) { create(:game, platform: platform, name: 'Dark Soul 3') }
    let!(:game_3) { create(:game, platform: platform, name: 'Super Mario') }
    let(:name) { 'soul' }

    it { is_expected.to match_array([game_1, game_2]) }
  end

  describe '::search_by_platform' do
    subject { described_class.search_by_platform(id) }

    let!(:ps4) { create(:platform, id: 1, name: 'PS4') }
    let!(:NS) { create(:platform, id: 2, name: 'NS') }
    let!(:ps4_games) { create_list(:game, 2, platform_id: 1) }
    let!(:ns_games) { create_list(:game, 3, platform_id: 2) }
    let(:id) { 1 }

    it { is_expected.to match_array(ps4_games) }
  end

  describe '#lowest_price' do
    subject { game.lowest_price }

    let!(:game) { create(:game) }

    context 'when game has stock' do
      before do
        create(:stock, :selling, game: game, price: 300)
        create(:stock, :selling, game: game, price: 100)
        create(:stock, :selling, game: game, price: 500)
      end

      it { is_expected.to eq 100 }
    end

    context 'when game do not have any stock' do
      it { is_expected.to eq game.price }
    end
  end

  describe '#best_available_stock' do
    subject { game.best_available_stock(user.id) }

    let!(:user) { create(:user) }
    let!(:game) { create(:game) }
    let!(:user_stock) do
      create(:stock, :selling, game: game, user: user, price: 100)
    end
    let!(:pending_stock) { create(:stock, :pending, game: game, price: 200) }
    let!(:best_available_stock) do
      create(:stock, :selling, game: game, price: 1000)
    end
    let!(:other_stock) { create(:stock, :selling, game: game, price: 1500) }

    it 'return stock with lowest price and not own by user' do
      expect(subject).to eq best_available_stock
    end
  end
end
