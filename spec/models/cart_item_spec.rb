# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let!(:user) { create(:user, id: 1) }
  let!(:stock) { create(:stock, id: 10, price: stock_price, quantity: stock_quantity) }
  let(:stock_price) { 1500 }
  let(:stock_quantity) { 100 }
  let(:quantity) { 10 }
  let(:detail) do
    {
      game_id: stock.game_id,
      game_name: stock.game_name,
      owner_email: stock.user.email,
      owner_id: stock.user.id,
      stock_quantity: stock.quantity
    }.to_json
  end
  let(:item) { described_class.new(user.id, stock.id).tap { |item| item.quantity = quantity } }

  before(:each) { Redis.new.flushdb }

  describe '#initialize' do
    it 'create id by user_id:stock_id' do
      expect(item.id).to eq "#{user.id}:#{stock.id}"
    end

    subject { described_class.new(user.id, stock.id) }
    context 'when item not exist in redis' do
      it 'create cart_item with 0 quantity' do
        expect(subject.quantity.value).to eq 0
      end
    end

    context 'when item exist in redis' do
      before { item }

      it 'read it with correct detail' do
        expect(subject.detail).to eq detail
        expect(subject.quantity.value).to eq quantity
        expect(subject.price.value).to eq stock_price
      end
    end
  end

  describe '#quantity' do
    subject { item.quantity.value }

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
    end

    context 'when number is negative' do
      let(:number) { -10 }
      it 'will raise InvalidQuantity' do
        expect { subject }.to raise_error CartItem::InvalidQuantity
      end
    end
  end

  describe '#increment' do
    subject { item.increment(number) }

    context 'when increase more than stock has' do
      let(:number) { 1000 }

      it 'will raise InvalidQuantity' do
        expect { subject }.to raise_error CartItem::InvalidQuantity
      end
    end

    context 'when increase with negative vaule' do
      let(:number) { -1 }
      it 'will raise InvalidQuantity' do
        expect { subject }.to raise_error CartItem::InvalidQuantity
      end
    end

    context 'when increase not more than stock has' do
      let(:number) { 10 }
      it { is_expected.to eq quantity + number }
    end
  end

  describe '#total_price' do
    subject { item.total_price }

    it { is_expected.to eq quantity * stock_price }
  end

  describe '#stock' do
    subject { item.stock }

    it { is_expected.to eq stock }
  end

  describe '#clear' do
    subject { item.clear }

    before { allow(item).to receive(:redis_delete_objects) }

    it 'clear object data stored in redis' do
      subject
      expect(item).to have_received(:redis_delete_objects)
    end
  end

  describe '#latest?' do
    subject { read_item.latest? }

    let(:read_item) { described_class.new(user.id, stock.id) }

    before { item }

    context 'when stock price change' do
      before { stock.update(price: 10_000) }
      it { is_expected.to be_falsey }
    end

    context 'when quantity not enough' do
      before { stock.update(quantity: 1) }
      it { is_expected.to be_falsey }
    end

    context 'when quantity is enough' do
      before { stock.update(quantity: 10_000) }
      it { is_expected.to be_truthy }
    end
  end

  describe '#checkout' do
    subject { item.checkout }

    before { allow(item.stock).to receive(:reduce_quantity!) }

    context 'when invalid' do
      before { allow(item).to receive(:valid?).with(:checkout).and_return(false) }
      it { is_expected.to be_falsey }
    end

    context 'when valid' do
      before { allow(item).to receive(:valid?).with(:checkout).and_return(true) }

      it 'will reduce quantity from stock' do
        subject
        expect(item.stock).to have_received(:reduce_quantity!)
      end
    end
  end

  describe '#quantity_should_be_positive' do
    subject { item.send(:quantity_should_be_positive) }

    context 'when quantity is negative' do
      before { item.quantity.value = -10 }
      it { is_expected.to be_falsey }
    end
  end
end
