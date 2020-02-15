Rails.application.routes.draw do

  root 'sessions#new'
  get 'sessions/new'
  # post 'sessions/create'
  post 'sessions/create', to: 'sessions#create'
  delete 'sessions/destroy'
  get 'sessions/updateNew'
  post 'sessions/updateCreate'

  get 'works/main'
  post 'works/action'
  post 'works/back'

  #adminsにアクセスしたときの動き
  get 'admins/main'
  get 'admins/progress'
  get 'admins/preprocess'

  get 'admins/post'
  get 'admins/avg'
  delete 'admins/destroyFile'
  delete 'admins/destroyUser'
  post 'admins/display'
  post 'admins/hidden'

  post 'admins/add_file', to: 'admins#add_file'
  post 'admins/create_allocation', to: 'admins#create_allocation'

  # get '/login', to: 'sessions#new'
  # post '/login', to: 'sessions#create'
  # delete '/logout', to: 'sessions#destroy'

  resources :users
end
