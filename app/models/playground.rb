class Playground < ApplicationRecord
  belongs_to :user
  has_many :diaries, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :playground_tags, dependent: :destroy
  has_many :tags, through: :playground_tags
end
