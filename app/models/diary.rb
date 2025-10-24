class Diary < ApplicationRecord
  belongs_to :user
  belongs_to :playground, optional: true   # ← ✅ この1行を追加・修正！
  has_one_attached :image

  validates :title, :content, presence: true
end
