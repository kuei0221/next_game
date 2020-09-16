# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :game, dependent: :destroy
  belongs_to :user, dependent: :destroy

  delegate :name, :price, to: :game, prefix: true

  validates :type, inclusion: { in: %w[Stock OrderItem] }

  include AASM

  enum state: { pending: 0, selling: 1, shipping: 2, sold: 3 }

  aasm column: :state, enum: true do
    state :pending, initial: true
    state :selling
    state :shipping
    state :sold

    event :open, guard: :stock? do
      transitions from: :pending, to: :selling
    end

    event :close, guard: :stock? do
      transitions from: :selling, to: :pending
    end

    event :complete, guard: :order_item do
      transitions from: :shipping, to: :sold
    end
  end

  def stock?
    type == 'Stock'
  end

  def order_item?
    type == 'OrderItem'
  end
end
