Rails.application.routes.draw do
  apipie
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root 'apipie/apipies#index'

  get 'api/rick_and_morty_characters', to: 'rick_and_morty_characters#index'
end
