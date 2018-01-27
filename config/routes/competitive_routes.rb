Avicus::Application.routes.draw do
  resources :teams do
    collection do
      get ':id/set_role' => 'teams#set_role'
      get ':id/set_accepted' => 'teams#set_accepted'
      get ':id/kick' => 'teams#kick'
      get ':id/leave' => 'teams#leave'
      get ':id/invite' => 'teams#invite'
      get ':id/cancel_invite' => 'teams#cancel_invite'
      get ':id/stats' => 'teams#stats'
    end
  end

  scope 'scrims' do
    get '' => 'slots#index', :as => 'scrims'

    get 'server_count' => 'slots#server_count', :as => 'server_count'

    get ':id' => 'slots#view', :as => 'scrim'
    post 'create' => 'slots#create', :as => 'create_scrim'

    get ':id/cancel' => 'slots#cancel', :as => 'cancel_scrim'
  end

  resources :tournaments do
    get 'loner' => 'registrations#alone'
    resources :registrations do
      get 'toggle' => 'registrations#toggle'
      get 'accept' => 'registrations#accept'
      get 'uninvite' => 'registrations#uninvite'
      post 'invite' => 'registrations#invite'
    end
  end
end
