Fiso5as::Application.routes.draw do
  resources :matches, only: %i( index show new create )
  get '/admin' => 'game_weeks#index'

  get '/:season/:game_week/:fixture' => 'matches#show'
  get '/:access_token' => 'matches#index', as: :gw
  root to: "matches#index"
end
