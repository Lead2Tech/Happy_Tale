Rails.application.routes.draw do
  get 'home/index'

  # Defines the root path route ("/")
  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
