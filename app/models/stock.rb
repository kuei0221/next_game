# frozen_string_literal: true

class Stock < ApplicationRecord
  include AASM

  belongs_to :game, dependent: :destroy
  belongs_to :user, dependent: :destroy
  scope :not_own_by_current_user, ->(user_id) { where.not(user_id: user_id) }

  validates :user_id, uniqueness: { scope: :game_id, message: 'already has the stock of this game' }
  delegate :id, :name, :price, to: :game, prefix: true

  enum state: { pending: 0, selling: 1, shipping: 2, sold: 3}

  attribute :type, default: 'Stock'

  aasm column: :state, enum: true do
    state :pending, initial: true
    state :selling
    state :shipping
    state :sold

    event :open do
      transitions from: :pending, to: :selling
    end

    event :close do
      transitions from: :selling, to: :pending
    end
  end

  def is_users?(user_id)
    
    self.user_id == user_id
  end
  
  def reduce_quantity!(num)
    raise ArgumentError unless num > 0

    decrement!(:quantity, num)
  end
end
