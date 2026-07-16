Rails.application.routes.draw do
  devise_for :users

  root "urls#index"

  resources :urls, only: [:index, :create, :destroy] do
    member do
      get :qr_code
      get :analytics
    end
    collection do
      get :click_counts  # JSON endpoint for real-time polling
      post :expand
      post :lengthen
    end
  end

  namespace :api do
    namespace :v1 do
      resources :urls, only: [:index, :create, :show, :destroy]
      get "me", to: "users#show"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "version" => proc {
    [200,
     { "Content-Type" => "application/json" },
     [{ version: APP_VERSION, deployed_at: Rails.application.config.x.deployed_at }.to_json]]
  }

  # Short URL redirect — must be last
  get "/:short_code", to: "redirect#show", as: :redirect_short_url
end
