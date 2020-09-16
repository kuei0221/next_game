# frozen_string_literal: true

class Platform < ApplicationRecord
  has_many :games, dependent: :destroy
end
