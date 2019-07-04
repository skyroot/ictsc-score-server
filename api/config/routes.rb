# frozen_string_literal: true

Rails.application.routes.draw do
  scope '/api', defaults: { format: 'json' } do
    get 'sessions', to: 'sessions#current'
    post 'sessions', to: 'sessions#login'
    delete 'sessions', to: 'sessions#logout'

    get 'health', to: 'health#health'
    post 'graphql', to: 'graphql#execute'
  end
end