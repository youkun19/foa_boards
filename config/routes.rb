Rails.application.routes.draw do
  get 'boards/show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :boards, only: [:show]
end
