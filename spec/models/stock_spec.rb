# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Stock, type: :model do
  let!(:stock) { create(:stock, quantity: 10) }

  it do
    should validate_uniqueness_of(:user_id)
      .scoped_to(:game_id)
      .with_message('already has the stock of this game')
  end

  describe '#reduce_quantity!' do
    subject { stock.reduce_quantity!(num) }

    context 'when num is positive' do
      let(:num) { 1 }
      it { is_expected.to eq 9 }
    end

    context 'when num is negative' do
      let(:num) { -1 }
      it do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context 'when num is more than quantity of stock' do
      let(:num) { 20 }
      it do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end
end
