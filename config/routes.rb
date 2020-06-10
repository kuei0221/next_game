# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'games#index'
  devise_for :users, controllers: { sessions: 'users/sessions' }

  # get 'games/show'
  resources :games, only: :show
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
