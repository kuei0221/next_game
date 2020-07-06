# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StockForm do
  let!(:game) { create(:game) }
  let!(:user) { create(:user) }

  describe '#initialize' do
    subject { described_class.new(params) }

    context 'when create new stock' do
      let(:params) { { game_id: game.id, price: 1000, quantity: 1, user_id: user.id } }
      it { is_expected.to be_valid }
      it { expect(subject.stock_id).to eq nil }
    end

    context 'when update exist stock' do
      let!(:stock) { create(:stock, id: 1, game_id: game.id, user_id: user.id) }
      let(:params) { {stock_id: 1, price: 500, quantity: 10, user_id: user_id, state: 1 } }
      let(:user_id) { user.id }

      it { is_expected.to be_valid }

      context 'when stock not own by user' do
        let(:user_id) { 10_000 }

        it { is_expected.to be_invalid }
      end
    end
  end

  describe '#save' do
    subject { form.save }

    let(:form) { described_class.new(params) }

    context 'when creating new stock' do
      let(:params) { { game_id: game_id, price: price, quantity: quantity, user_id: user.id } }
      let(:game_id) { game.id }
      let(:price) { 1000 }
      let(:quantity) { 1 }

      context 'with correct data' do
        it { is_expected.to be_truthy }
      end

      context 'when user already have the stock of the game' do
        let!(:stock) { create(:stock, game_id: game_id, user_id: user.id, price: price, quantity: quantity) }
        it { is_expected.to be_falsey }
        it 'should have child error message' do
          subject
          expect(form.errors.full_messages).to include 'User already has the stock of this game'
        end
      end

      context 'when game_id is invalid' do
        let(:game_id) { 100_000 }
        it { is_expected.to be_falsey }
      end

      context 'with negative quantity' do
        let(:quantity) { -10 }
        it { is_expected.to be_falsey }
      end

      context 'with negative price' do
        let(:price) { -1000 }
        it { is_expected.to be_falsey }
      end

      context 'with price higher than game price' do
        let(:price) { 10_000 }
        it { is_expected.to be_falsey }
        it 'should have error message' do
          subject
          expect(form.errors.full_messages).to include 'Price cannot greater than game price'
        end
      end
    end

    context 'when update exist stock' do
      let!(:stock) { create(:stock, id: 1, game_id: game.id, price: 1000, user_id: user.id, quantity: 1, state: 0) }
      let(:form) { described_class.new(params) }
      let(:params) { { price: stock_price, quantity: 10, state: 1, stock_id: stock_id, user_id: user.id } }
      let(:stock_id) { 1 }
      let(:stock_price) { 500 }

      context 'with correct data' do
        it 'should change stock' do
          expect { subject }.to change { stock.reload.price }.from(1000).to(500).and \
            change { stock.reload.quantity }.from(1).to(10).and \
              change { stock.reload.state }.from('pending').to('selling')
        end

        it { is_expected.to be_truthy }
      end

      context 'with invalid stock id' do
        let(:stock_id) { 100 }
        it { is_expected.to be_falsey }
        it { expect(form.game_id).to eq nil }
      end

      context 'with negative price' do
        let(:stock_price) { 1_000_000 }
        it { is_expected.to be_falsey }
      end
    end
  end
end
