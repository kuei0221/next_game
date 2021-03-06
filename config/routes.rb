# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'games#index'
  devise_for :users, controllers: { confirmations: 'users/confirmations', }

  resources :games, only: %i[show index]
  resources :stocks, only: %i[index show create update destroy]
  resource :cart, only: :show do
    collection do
      post :add, path: 'add'
      patch :change, path: 'change'
      delete :remove, path: 'remove'
    end
  end

  resources :orders, only: %i[new create]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
