class Diary < ApplicationRecord
  belongs_to :user
  belongs_to :playground, optional: true
  has_one_attached :image

  validates :title, :content, presence: true

  # ✅ 日付文字列を Date 型に正しく変換（Safari対策含む）
  def visited_at=(value)
    super(value.is_a?(String) ? Date.parse(value) : value)
  rescue ArgumentError
    super(nil)
  end
end
