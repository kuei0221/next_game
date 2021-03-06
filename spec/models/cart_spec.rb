# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cart do
  let(:cart) { described_class.new(user.id) }
  let!(:user) { create(:user, id: 1) }
  let!(:stock) { create(:stock, quantity: stock_quantity) }
  let(:stock_quantity) { 10 }
  let(:item) { double('cart_item') }
  let(:quantity) { 10 }
  before(:each) { Redis.new.flushdb }

  before do
    allow(CartItem).to receive(:new).and_return(item)
    allow(item).to receive(:quantity=)
    allow(item).to receive(:increment)
    allow(item).to receive(:clear).and_return(true)
    allow(item).to receive(:valid?).and_return(true)
  end

  describe '#cart_items' do
    subject { cart.cart_items }
    let(:stocks) { create_list(:stock, 3) }
    before do
      stocks.each { |stock| cart.items << stock.id }
    end

    it 'return array of CartItem' do
      expect(subject.all?(item)).to eq true
    end
    it 'initialzize CartItem' do
      subject
      expect(CartItem).to have_received(:new).exactly(3).times
    end
  end

  describe '#add_item' do
    subject { cart.add_item(stock.id, quantity) }

    context 'when item is not in cart' do
      it 'add stock_id in items' do
        expect { subject }.to change { cart.items.value }
          .from([]).to([stock.id.to_s])
      end
      it 'assign quantity to item' do
        subject
        expect(item).to have_received(:quantity=).with(quantity)
      end
    end

    context 'when item is in cart' do
      before { cart.items << stock.id }
      it 'will increase the quantity of item' do
        subject
        expect(item).to have_received(:increment).with(quantity)
      end
    end
  end

  describe '#change_item' do
    subject { cart.change_item(stock.id, new_quantity) }

    let(:new_quantity) { 100 }

    before { cart.items << stock.id }

    it 'assign new quantity to item' do
      subject
      expect(item).to have_received(:quantity=)
    end
  end

  describe '#remove_item' do
    subject { cart.remove_item(stock.id) }
    before { cart.items << stock.id }

    it 'remove item from items and clear item' do
      expect { subject }.to change { cart.items.value }.from([stock.id.to_s]).to([])
    end

    it 'clear item' do
      subject
      expect(item).to have_received(:clear)
    end
  end

  describe '#total_price' do
    subject { cart.total_price }

    let(:stock_1) { create(:stock, price: 1000) }
    let(:stock_2) { create(:stock, price: 1500) }
    context 'when no items' do
      it { is_expected.to eq 0 }
    end
    context 'when has items' do
      before do
        cart.items << stock_1.id
        cart.items << stock_2.id
        allow(item).to receive(:total_price).and_return(1)
      end
      it 'sum up all items total price' do
        subject
        expect(item).to have_received(:total_price).twice
      end
    end
  end

  describe '#clear!' do
    subject { cart.clear! }
    before { cart.items << stock.id }

    it 'clear items' do
      expect { subject }.to change { cart.items }.from([stock.id.to_s]).to([])
    end
    it 'clear all cart items' do
      subject
      expect(item).to have_received(:clear)
    end
  end

  describe '#checkout!' do
    subject { cart.checkout! }

    let(:stock_1) { create(:stock, price: 1000) }
    let(:stock_2) { create(:stock, price: 1500) }

    before do
      cart.add_item(stock_1.id, 3)
      cart.add_item(stock_2.id, 2)
    end

    context 'when checkout success' do
      before { allow(item).to receive(:checkout).and_return(true) }
      it { is_expected.to be_nil }
    end

    context 'when checkout fail' do
      before do
        allow(item).to receive(:checkout).and_return(false)
        allow(cart).to receive(:gather_error!)
        allow(cart.errors).to receive(:any?).and_return true
      end

      it do
        expect { subject }.to raise_error Cart::CheckoutError
      end
    end
  end

  describe '#register!' do
    let(:cart) { described_class.new('test_session_cart_id') }
    before do
      allow(cart.items).to receive(:rename).and_return(true)
      allow(cart.uuid).to receive(:rename).and_return(true)
    end

    subject { cart.register!(user.id) }

    it 'should change user_id' do
      expect { subject }.to change { cart.user_id }.from('test_session_cart_id').to(user.id)
    end
    it 'should rename redis key of items and uuid' do
      subject
      expect(cart.items).to have_received(:rename).with("cart:#{user.id}:items")
      expect(cart.uuid).to have_received(:rename).with("cart:#{user.id}:uuid")
    end
  end
end
