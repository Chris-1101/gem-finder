Rails.application.routes.draw do

  get "properties", to: "pages#properties"
  get "about", to: "pages#about"
  get "contact", to: "pages#contact"
  get "home", to: "pages#home"




  get 'user/new'
  get 'user/create'
  get 'user/show'
  get 'user/destroy'
  get 'user/edit'
  get 'user/update'
  get 'property/index'
  get 'property/show'
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
