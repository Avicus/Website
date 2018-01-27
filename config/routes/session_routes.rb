Avicus::Application.routes.draw do
  get 'login' => 'pages#login'
  post 'login' => 'pages#login'
  get 'logout' => 'pages#logout'
end
