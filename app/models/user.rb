class User < ApplicationRecord
  # Deviseの基本モジュール
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 関連
  has_many :playgrounds, dependent: :destroy
  has_many :diaries, dependent: :destroy
  has_many :favorites, dependent: :destroy

  # バリデーション
  validates :nickname, presence: true, length: { maximum: 50 }
  validates :name, presence: true, length: { maximum: 50 }
end
