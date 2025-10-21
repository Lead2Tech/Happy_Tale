class Tag < ApplicationRecord
  has_many :playground_tags, dependent: :destroy
  has_many :playgrounds, through: :playground_tags
end
