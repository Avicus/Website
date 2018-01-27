Avicus::Application.routes.draw do
  namespace :admin do
    get '' => 'index#index'
    get 'ip/:id' => 'index#ip'
    post 'punish' => 'index#punish'

    # Stats
    scope 'stats' do
      get '' => 'stats#main'
      get 'weekday' => 'stats#weekday'
      get 'credits' => 'stats#credits'
      get 'versions' => 'stats#versions'
      get 'punishments' => 'stats#punishments'
      get 'appeals' => 'stats#appeals'
      get 'appeal_resolutions' => 'stats#appeal_resolutions'
    end

    # Ranks
    resources 'ranks' do
      get 'copy' => 'ranks#copy', as: 'copy'
      post 'members/new' => 'members#add'
      patch 'members/:id' => 'members#update', as: 'update_member'
      resources :members
    end

    # Servers
    resources :servers

    # Server Categories
    resources :server_categories do
      post 'add_member' => 'server_categories#add_member', as: 'add_member'
      get 'remove_member' => 'server_categories#remove_member', as: 'remove_member'
    end

    # Server Groups
    resources :server_groups do
      post 'add_member' => 'server_groups#add_member', as: 'add_member'
      get 'remove_member' => 'server_groups#remove_member', as: 'remove_member'
    end

    # Achievements
    resources :achievements do
      post 'reward' => 'achievements#reward', as: 'reward'
      get 'revoke' => 'achievements#revoke', as: 'revoke'
    end

    # Announcements
    resources :announcements do
      get 'copy' => 'announcements#copy', as: 'copy'
    end

    # Forums
    get 'forums' => 'forums#index'
    post 'forums/create' => 'forums#create_forum', as: 'forums_create'
    get 'forums/:id' => 'forums#edit_forum', as: 'forums_edit'
    post 'forums/:id' => 'forums#update_forum', as: 'forums_update'
    delete 'forums/:id' => 'forums#destroy_forum', as: 'forums_destroy'
    post 'categories/create' => 'forums#create_category', as: 'categories_create'
    get 'categories/:id' => 'forums#edit_category', as: 'categories_edit'
    post 'categories/:id' => 'forums#update_category', as: 'categories_update'
    delete 'categories/:id' => 'forums#destroy_category', as: 'categories_destroy'
  end
end
