Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  root 'home#index'
  # devise_for :admins
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :admin do
    resources :loans, only: [:index] do
      member do
        patch :approve
        get :get_modal_popup
        patch :reject
        patch :confirm
      end
    end
  end

  resource :wallet, only: [:show]
  resources :loan_adjustments, only: [:show, :index] do
    member do
      patch :adjust_loan
    end
  end

  resources :loans do
    member do
      patch :reject
      patch :confirm
      patch :request_readjustment
      patch :repay
    end
  end
end
