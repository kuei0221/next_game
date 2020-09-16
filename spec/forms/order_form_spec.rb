# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderForm do
  let!(:buyer) { create(:user) }
  let!(:sellers) { create_list(:user, 2) }
  let!(:stock1) { create(:stock, user: sellers[0], quantity: 5) }
  let!(:stock2) { create(:stock, user: sellers[1], quantity: 3) }
  let(:cart) { Cart.new(buyer.id) }
  let(:form) { described_class.new(buyer.id) }
  
  before(:each) { Redis.new.flushdb }

  describe "#save" do

    before do
      cart.add_item(stock1.id, 2)  
      cart.add_item(stock2.id, 1)
      allow(form.cart).to receive(:clear!)
    end

    subject { form.save }

    context 'when success' do
      let(:order) { { buyer_id: buyer.id, price: (stock1.price * 2 + stock2.price * 1) }.with_indifferent_access }
      let(:order_item1) { { game_id: stock1.game_id, user_id: sellers[0].id, price: stock1.price, quantity: 2, state: 'shipping' }.with_indifferent_access }
      let(:order_item2) { { game_id: stock2.game_id, user_id: sellers[1].id, price: stock2.price, quantity: 1, state: 'shipping' }.with_indifferent_access }

      it 'create order, order item and reduce stock quantity' do
        expect { subject }.to change { Order.count }.from(0).to(1).and \
          change { OrderItem.count }.from(0).to(2).and \
            change { Stock.first.quantity }.from(5).to(3).and\
              change { Stock.second.quantity }.from(3).to(2)
      end


      it 'should create correct order and order item' do
        subject
        expect(form.order.attributes).to be > order
        expect(form.order.items.first.attributes).to be > order_item1 
        expect(form.order.items.second.attributes).to be > order_item2 
      end
  
      it 'clear cart and cart item' do
        subject
        expect(form.cart).to have_received(:clear!)
      end

      it { is_expected.to be_truthy }
    end

    context 'when checkout fail' do
      before { allow_any_instance_of(Cart).to receive(:checkout!).and_raise(Cart::CheckoutError) }

      context 'Cart::CheckoutError will be rescue and add in errors' do
        before { allow_any_instance_of(ActiveModel::Errors).to receive(:add) }
        
        it 'will add message in error' do
          subject
          expect(form.errors).to have_received(:add).with(:cart, Cart::CheckoutError.new.message)
        end
      end

      it { is_expected.to be_falsey }

      it 'will not create order' do
        expect { subject }.not_to change { Order.count }
      end

      it 'will not create order item ' do
        expect { subject }.not_to change { OrderItem.count }
      end

      it 'will not change stock quantity' do
        expect { subject }.not_to change { Stock.first.quantity }
        expect { subject }.not_to change { Stock.second.quantity }
      end
     
      it 'will not clear cart' do
        subject
        expect(form.cart).not_to have_received(:clear!)
      end

    end

    context 'when order create fail' do
      before { allow_any_instance_of(Order).to receive(:save!).and_raise(ActiveRecord::RecordInvalid) }

      it { is_expected.to be_falsey }

      context 'ActiveRecord::RecordInvalid will be rescue and add in errors' do
        before { allow_any_instance_of(ActiveModel::Errors).to receive(:add) }
        
        it 'will add message in error' do
          subject
          expect(form.errors).to have_received(:add).with(:order, ActiveRecord::RecordInvalid.new.message)
        end
      end
    end
  end
end
