Rails.application.routes.draw do
  resources :repos, only: %i[ index show ]

  get '/readyz' => 'healthcheck#readyz'
  get '/livez'  =>  'healthcheck#livez'
  get '/revisionz'  =>  'healthcheck#revisionz'

  root to: redirect('repos')
end
