Rails.application.routes.draw do

  resources :users, :links
  get 'links/:id' => 'links#show'
  get 'links' => 'links#index'

  get 'home/index'

  post 'users/createuser' => 'users#create'
  post 'users/:id/createcard' => 'users#createcard'
  post 'users/:id/createlink' => 'users#createlink'

  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
