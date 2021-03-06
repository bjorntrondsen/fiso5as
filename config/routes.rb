Fiso5as::Application.routes.draw do
  resources :matches, only: %i( index show new create )
  resources :game_weeks, only: %i( index )
  get '/admin' => 'game_weeks#index'

  namespace :fiveaside do
    get '/:season/:game_week/:fixture' => 'matches#show'
    get '/:access_token' => 'matches#index', as: :gw
  end

  root to: "landing_page#index"
end
