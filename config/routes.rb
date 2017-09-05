Fiso5as::Application.routes.draw do
  resources :matches, only: %i( index show new create )
  get '/admin' => 'game_weeks#index'

  namespace :fiveaside do
    get '/:season/:game_week/:fixture' => 'matches#show'
    get '/:access_token' => 'matches#index', as: :gw
  end

  root to: "matches#index"
end
