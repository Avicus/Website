Avicus::Application.routes.draw do
  scope 'users' do
    get '' => redirect('/stats')
    get 'search' => 'users#search'

    # Registration
    get 'register' => 'users#register', :as => 'registration'
    post 'register' => 'users#registration_start', :as => 'registration_start'
    get 'register/:user_id' => 'users#registration_status', :as => 'registration_status'
    get 'registered/:user_id' => 'users#registration_success', :as => 'registration_success'

    get 'discord-auth' => 'users#discord_auth'

    scope ':user' do
      get '' => 'users#profile'
      get 'status' => 'users#status'
      get 'edit' => 'users#edit', :as => 'edit_user'
      get 'generate-api-token' => 'users#generate_api_token'
      get 'posts' => 'users#posts'
      get 'graphs' => 'users#graphs'
      patch 'update' => 'users#update'

      get 'friends' => 'users#friends'

      get 'friend/add' => 'users#add_friend'
      get 'friend/accept' => 'users#accept_friend'
      get 'friend/cancel' => 'users#cancel_friend'
      get 'friend/remove' => 'users#remove_friend'
    end
  end
end
