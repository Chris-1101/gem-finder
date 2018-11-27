Rails.application.routes.draw do
  devise_for :users

  require "sidekiq/web"
  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: 'pages#home'
  get "about", to: 'pages#about'
  get "contact", to: 'pages#contact'

  resources :properties, only: [:index, :show, :new, :create]

  resources :users do
  #Possibly needs to be nested inside users.
    resources :trackings, only: [:index]
  end

  resources :conversations, only: [:create, :show, :index, :destroy] do
    resources :messages, only: [:create, :destroy]
  end

  resources :trackings, only: [:destroy, :create]

end
