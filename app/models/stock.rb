# frozen_string_literal: true

class Stock < Product
  scope :not_own_by_current_user, ->(user_id) { where.not(user_id: user_id) }

  validates :user_id, uniqueness: { scope: :game_id, message: 'already has the stock of this game' }

  attribute :state, default: :pending

  def users?(user_id)
    self.user_id == user_id
  end

  def reduce_quantity!(num)
    raise ArgumentError unless num.positive? && quantity >= num

    decrement(:quantity, num)
    return quantity if save
  end
end
