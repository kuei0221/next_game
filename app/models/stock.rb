# frozen_string_literal: true

class Stock < Product
  
  scope :not_own_by_current_user, ->(user_id) { where.not(user_id: user_id) }
  
  validates_uniqueness_of :user_id, scope: :game_id, message: 'already has the stock of this game'
  
  attribute :state, default: :pending

  def is_users?(user_id)
    
    self.user_id == user_id
  end
  
  def reduce_quantity!(num)
    raise ArgumentError unless num > 0 && quantity >= num

    decrement!(:quantity, num)
    self.quantity
  end
end
