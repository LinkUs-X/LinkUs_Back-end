Rails.application.routes.draw do

  resources :users, :links, :cards
  get 'cards/:id' => 'cards#show'
  get 'cards' => 'cards#index'

  get 'links/:id' => 'links#show'
  get 'links' => 'links#index'

  get 'home/index'

  post 'users/createuser' => 'users#create'
  get 'users/:id/newcard' => 'users#newcard', as: 'newcard'
  get 'users/:id/newlink' => 'users#newlink', as: 'newlink'
  get 'users/:id/showcardsbyuser' => 'users#showcardsbyuser', as: 'showcardsbyuser' 
  get 'users/:id/showlinksbyuser' => 'users#showlinksbyuser', as: 'showlinksbyuser'
  post 'users/:id/createcard' => 'users#createcard'
  post 'users/:id/createlink' => 'users#createlink'

  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
