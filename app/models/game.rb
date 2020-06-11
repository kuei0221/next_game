class Game < ApplicationRecord
  belongs_to :platform
  has_one_attached :cover
end
