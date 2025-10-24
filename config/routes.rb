Rails.application.routes.draw do
  devise_for :users

  # ✅ 正しいCRUDルート
  resources :diaries
  resources :playgrounds

  get 'home/index'
  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
