Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :boards, only: [:show]
  resources :kakunin_boards, only: [:show]
  resources :comments
end
