Rails.application.routes.draw do

  resources :links
  get 'links/:user_id' => 'links#showlinks'
  get 'links' => 'links#index'

  resources :users
  get 'home/index'

  post 'users/createuser' => 'users#create'
  post 'users/:id/createcard' => 'users#createcard'
  post 'users/:id/createlink' => 'users#createlink'

  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
