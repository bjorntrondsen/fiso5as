Fiso5as::Application.routes.draw do
  resources :matches, only: %i( index show new create )
  resources :game_weeks, only: %i( index )
  get '/:access_key' => 'matches#index', as: :gw
  root to: "matches#index"
end
