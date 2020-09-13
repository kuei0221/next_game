# frozen_string_literal: true

class Game < ApplicationRecord
  belongs_to :platform
  has_one_attached :cover
  has_many :stocks, -> { selling.order(price: :asc, updated_at: :desc) }

  scope :search_by_name, ->(name) { where('name ilike ?', "%#{name}%") }
  scope :search_by_platform, ->(id) { where('platform_id': id) }

  def lowest_price
    stocks.any? ? stocks.first.price : price
  end

  def best_available_stock(user_id)
    stocks.not_own_by_current_user(user_id.to_i).first
  end

  def total_quantity
    stocks.sum(:quantity)
  end
end
