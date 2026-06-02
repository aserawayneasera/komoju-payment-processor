Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login",    to: "auth#login"

      resources :api_keys,          only: [:index, :create, :destroy]
      resources :customers,         only: [:index, :create, :show] do
        resources :payment_methods, only: [:index, :create]
      end
      resources :charges,           only: [:index, :create, :show] do
        resources :refunds,         only: [:create]
      end
      resources :webhook_endpoints, only: [:index, :create, :destroy]
      resources :events,            only: [:index, :show]
    end
  end
end
