class Diary < ApplicationRecord
  belongs_to :user
  belongs_to :playground
  has_one_attached :image

  validates :title, :content, presence: true
end
