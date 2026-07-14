Rails.application.routes.draw do
  devise_for :users

  root "urls#index"

  resources :urls, only: [:index, :create, :destroy] do
    member do
      get :qr_code
      get :analytics
    end
  end

  namespace :api do
    namespace :v1 do
      resources :urls, only: [:index, :create, :show, :destroy]
      get "me", to: "users#show"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # Short URL redirect — must be last
  get "/:short_code", to: "redirect#show", as: :redirect_short_url
end
