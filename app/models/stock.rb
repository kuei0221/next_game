# frozen_string_literal: true

class Stock < ApplicationRecord
  include AASM

  belongs_to :game
  belongs_to :user, dependent: :destroy

  validates :user_id, uniqueness: { scope: :game_id, message: 'already has the stock of this game'}

  delegate :id, :name, :price, to: :game, prefix: true

  enum state: { pending: 0, selling: 1 }

  aasm column: :state, enum: true do
    state :pending, initial: true
    state :selling

    event :open do
      transitions from: :pending, to: :selling
    end

    event :close do
      transitions from: :selling, to: :pending
    end
  end
end
