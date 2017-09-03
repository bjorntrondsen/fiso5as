Fiso5as::Application.routes.draw do
  resources :matches, only: [:index, :show, :new, :create]
  get '/:access_key' => 'matches#index'
  root to: "matches#index"
end
