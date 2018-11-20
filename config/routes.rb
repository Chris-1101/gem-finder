Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get "about", to: 'pages#about'
  get "contact", to: 'pages#contact'
  resources :properties, only: [:index, :show]
  resources :users do
  #Possibly needs to be nested inside users.
    resources :trackings, only: [:index]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  end
  resources :trackings, only: [:destroy, :create]
end
