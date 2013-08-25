Fiso5as::Application.routes.draw do
  resources :matches, only: [:index, :show]
  root to: "matches#index"
end
