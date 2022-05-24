# frozen_string_literal: true

Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  resources :users, only: %i[index]
  get '/user/profile', to: 'users#show_profile'

  resources :posts
  resources :comments, only: %i[create update destroy]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
