# == Route Map
#

Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  
  resources :users, only: [:index, :update, :destroy, :show]
  get '/user/profile', to: 'users#show_profile'

  resources :posts
  resources :comments

end
