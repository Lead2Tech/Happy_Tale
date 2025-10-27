Rails.application.routes.draw do
  devise_for :users

  # 🏠 TOPページ
  root "home#index"
  get "home/index"

  # 🗺 遊び場
  get "playgrounds/search_mode", to: "playgrounds#search_mode"  # ← これを上に！
  resources :playgrounds

  # 📔 日記
  resources :diaries

  # ✅ Railsヘルスチェック
  get "up" => "rails/health#show", as: :rails_health_check
end
