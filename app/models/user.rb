class User < ApplicationRecord
  has_many :playgrounds, dependent: :destroy
  has_many :diaries, dependent: :destroy
  has_many :favorites, dependent: :destroy
end
