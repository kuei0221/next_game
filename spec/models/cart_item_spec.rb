# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let(:item) { described_class.new(user.id, stock.id) }
  let!(:user) { create(:user, id: 1) }
  let!(:stock) { create(:stock, id: 10, price: stock_price, quantity: stock_quantity) }
  let(:stock_price) { 1500 }
  let(:stock_quantity) { 100 }
  let(:quantity) { 10 }
  let(:detail) do
    {
      'stock_id' => stock.id.to_s,
      'stock_quantity' => stock.quantity.to_s,
      'price' => stock.price.to_s,
      'quantity' => quantity.to_s,
      'game_id' => stock.game.id.to_s,
      'game_name' => stock.game.name,
      'owner_email' => stock.user.email
    }
  end
  before(:each) { Redis.new.flushdb }

  describe '#initialize' do

    it 'create id by user_id:stock_id' do
      expect(item.id).to eq '1:10'
    end

    subject { described_class.new(user.id, stock.id) }
    context 'when item not exist' do

      it 'create cart_item with 0 quantity' do
        expect(subject.quantity).to eq 0
      end
    end

    context 'when item exist' do
      before { item.quantity = quantity }

      it 'read it with correct detail' do
        expect(subject.detail.all).to eq detail
        expect(subject.quantity).to eq quantity
      end
    end
  end

  describe '#quantity' do
    subject { item.quantity }

    before { item.quantity = quantity }

    it { is_expected.to eq quantity }
  end

  describe '#quantity=' do
    subject { item.quantity = number }

    context 'when number smaller than stock_quantity' do
      let(:number) { 50 }
      it { is_expected.to eq number }
    end

    context 'when number larger than stock_quantity' do
      let(:number) { 200 }

      it 'will raise InvalidQuantity' do
        expect { subject }.to raise_error CartItem::InvalidQuantity
      end

      it 'will not change quantity' do
        expect(item.quantity).to eq 0
      end
    end
  end

  describe '#increment' do
    subject { item.increment(number) }
    before { item.quantity = quantity }

    context 'when increase more than stock has' do
      let(:number) { 1000 }
      it 'will raise InvalidQuantity' do
        expect { subject }.to raise_error CartItem::InvalidQuantity
      end
      it 'will not change quantity' do
        expect(item.quantity).to eq quantity
      end
    end

    context 'when increase not more than stock has' do
      let(:number) { 10 }
      it { is_expected.to eq quantity + number }
    end
  end

  describe '#total_price' do
    subject { item.total_price }
    before { item.quantity = quantity }

    it { is_expected.to eq quantity * stock_price }
  end

  describe '#stock' do
    subject { item.stock }

    it { is_expected.to eq stock }
  end

  describe '#clear' do
    subject { item.clear }
    before { item.quantity = quantity}

    it 'clear detail stored in redis' do
      expect { subject }.to change { item.detail.all }.from(detail).to({})
    end
  end
end
