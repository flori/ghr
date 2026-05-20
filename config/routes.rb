Rails.application.routes.draw do
  resources :repos, only: %i[ index ] do
    resources :releases, only: %i[ index ]
  end

  get '/repos/:repo_id', to: 'releases#index', as: :repo

  get '/readyz' => 'healthcheck#readyz'
  get '/livez'  => 'healthcheck#livez'
  get '/revisionz'  => 'healthcheck#revisionz'

  root to: redirect('repos')
end
