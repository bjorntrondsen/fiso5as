Fiso5as::Application.routes.draw do
  resources :matches, only: [:index, :show, :new, :create]
  root to: "matches#index"
end
