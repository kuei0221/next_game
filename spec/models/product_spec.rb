# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  it { should belong_to(:game).dependent(:destroy) }
  it { should belong_to(:user).dependent(:destroy) }
  it { should delegate_method(:name).to(:game).with_prefix }
  it { should delegate_method(:price).to(:game).with_prefix }
  it {
    should define_enum_for(:state).with_values(%i[pending selling shipping sold])
  }
  it { should have_db_index(:user_id) }
  it { should have_db_index(:game_id) }
  it { should have_db_index(:order_id) }
  it { should validate_inclusion_of(:type).in_array(%w[Stock OrderItem]) }

  let(:product) { create(:product, type: type) }
  let(:type) { '' }

  describe '#stock?' do
    subject { product.stock? }

    context 'when type is not stock' do
      let(:type) { 'OrderItem' }
      it { is_expected.to be_falsey }
    end

    context 'when type is stock' do
      let(:type) { 'Stock' }
      it { is_expected.to be_truthy }
    end
  end

  describe '#order_item?' do
    subject { product.order_item? }
    let(:type) { 'Stock' }
    context 'when type is not order_item' do
      it { is_expected.to be_falsey }
    end

    context 'when type is order item' do
      let(:type) { 'OrderItem' }
      it { is_expected.to be_truthy }
    end
  end
end
