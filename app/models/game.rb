# frozen_string_literal: true

class Game < ApplicationRecord
  belongs_to :platform
  has_one_attached :cover

  scope :search_by_name, ->(name) { where('name like ?', "%#{name}%") }
  scope :search_by_platform, ->(id) { where('platform_id': id) }
end
