# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartAddOperator do
  let!(:user) { create(:user) }
  let!(:game) { create(:game) }
  let!(:stock) { create(:stock, :selling, game: game) }
  let(:operator) { described_class.new(params) }

  describe "#perform" do
    subject { operator.perform }

    before { allow_any_instance_of(Cart).to receive(:add_item) }

    context 'when add from game' do
      let(:params) { { game_id: game_id, quantity: 3, cart_user_id: user.id } }
      
      context 'and game has stocks' do
        let(:game_id) { game.id }

        it 'should add item to cart' do
          expect_any_instance_of(Cart).to receive(:add_item).with(stock.id, 3)
          subject
        end

        it 'should find best stock and assign to stock_id' do
          expect { subject }.to change { operator.stock_id }.from(nil).to(stock.id)
        end
      end

      context 'and game does not have stocks' do
        let!(:game_without_stock) { create(:game) }
        let(:game_id) { game_without_stock.id }

        it 'should raise error NoStockExistError 'do
          expect { subject }.to raise_error CartAddOperator::NoStockExistError
        end
      end

      context 'and game does not exsit' do
        let(:game_id) { 999999999 }

        it 'should raise error ActiveRecord::RecordNotFound' do
          expect { subject }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    context 'when add from stock' do
      let(:params) { { stock_id: stock.id, quantity: 3, cart_user_id: user.id } }

      it 'should add item to cart' do
        expect_any_instance_of(Cart).to receive(:add_item).with(stock.id, 3)
        subject
      end
    end

    context 'when param inpu invalid' do
      let(:params) { { quantity: 3, cart_user_id: user.id } }

      it 'should raise error InvalidInput' do
        expect { subject }.to raise_error CartAddOperator::InvalidInput
      end
    end
  end
end
