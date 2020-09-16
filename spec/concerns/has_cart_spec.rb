# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples_for "has_cart" do
  let(:controller) { described_class.new } # the class that includes the concern
  let(:user) { create(:user) }
  let(:session) { Hash.new }

  before { allow(controller).to receive(:session).and_return(session) }

  describe "#cart_user_id" do
    subject { controller.send(:cart_user_id) }

    context 'when current_user exist' do
      before { allow(controller).to receive(:current_user).and_return(user) }
      it { is_expected.to eq user.id }
    end

    context 'when current_user not exist' do
      before { allow(controller).to receive(:current_user).and_return(nil) }
      
      context 'with cart_id in session' do
        before { session[:cart_id] = 'test id'}

        it { is_expected.to eq 'test id' }
      end

      context 'without anything in session' do
        before { allow(SecureRandom).to receive(:base64).and_return('test base64') }

        it { is_expected.to eq 'test base64' }
      end
    end
  end

  describe "#current_cart" do
    subject { controller.send(:current_cart) }
    before { allow(controller).to receive(:current_user).and_return(user) }

    it { is_expected.to be_decorated }
    it { is_expected.to be_a Cart }
  end
end
