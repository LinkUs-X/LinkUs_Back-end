Rails.application.routes.draw do
  resources :users
  get 'home/index'

  post 'users/:id/createcard' => 'users#createcard'

  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
