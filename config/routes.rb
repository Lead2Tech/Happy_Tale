Rails.application.routes.draw do
  devise_for :users
  
  # 🚫 ここを削除する（手動生成時にできた不要なルート）
  # get 'diaries/index'
  # get 'diaries/show'
  # get 'diaries/new'
  # get 'diaries/edit'

  # ✅ 正しいCRUDルート
  resources :diaries

  get 'home/index'
  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
