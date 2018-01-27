class ActionDispatch::Routing::Mapper
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end
end

unless ENV['daemon']
  Avicus::Application.routes.draw do

    if Rails.env.development?
      mount GraphiQL::Rails::Engine, at: '/graphic-api', graphql_path: '/api'
    end

    if Avicus::Application.app_mode == 'api'
      post '', to: 'graphql#execute'
      root 'pages#home_api'
    else
      # Peek
      mount Peek::Railtie => '/peek'

      # Blazer
      mount Blazer::Engine, at: 'blazer'

      resources :livestream, :path => :live

      resources :appeals
      get 'appeal' => 'appeals#appeal'

      scope 'alerts' do
        get '' => 'alerts#index', :as => 'alerts'
        get ':id' => 'alerts#delete', :as => 'destroy_alert'
      end

      scope 'servers' do
        get '' => 'servers#index'
      end

      scope 'stats' do
        get '' => 'stats#index'
      end

      scope 'experience' do
        get '' => 'stats#experience'
      end

      scope 'play', :controller => 'play' do
        get '' => 'play#index'
        get 'server/:server_id' => 'play#server'
        get 'players' => 'play#players'
      end

      scope 'maps', :controller => 'maps' do
        get '' => 'maps#index'
        get 'map/:map' => 'maps#map'
        get 'map/:map/ratings/:version' => 'maps#ratings'
        get 'category/:cat' => 'maps#category'
      end

      scope 'sessions' do
        get 'new' => 'sessions#new', :as => 'new_session'
        post 'new' => 'sessions#create', :as => 'create_session'
        delete '' => 'sessions#destroy', :as => 'destroy_session'
      end

      scope 'messages' do
        get '' => 'messages#index', :as => 'messages'
        get 'to-search' => 'messages#search'
        get 'compose' => 'messages#compose', :as => 'compose_message'
        post 'compose' => 'messages#create', :as => 'create_message'
        get 'delete' => 'messages#delete', :as => 'delete_message'
      end

      # Pages
      get 'staff' => 'pages#staff'
      get 'confirm/:uuid' => 'pages#confirm'
      get 'development' => 'pages#development'
      get 'development/:repo' => 'pages#development'

      # Legacy
      get 'revisions' => redirect('/development')
      get 'revisions/:repo' => redirect('/development//%{repo}')
      get 'register' => redirect('/users/register')

      # Handy Redirects
      %w(xp prestige prestiges).each do |xp|
        get "#{xp}" => redirect('/experience')
      end
      # Competitve
      get 'streams' => redirect('/live')
      get 'scrimmages' => redirect('/scrims')
      # Official
      get 'stafflist' => redirect('/staff')
      %w(infractions bans warns kicks).each do |punish|
        get "#{punish}" => redirect('/punishments')
      end

      resources :punishments
      post 'punish' => 'punishments#punish', :as => :punish

      draw 'admin_routes'
      draw 'competitive_routes'
      draw 'forum_routes'
      draw 'session_routes'
      draw 'user_routes'

      scope ':user' do
        get '' => 'users#profile', :as => 'user'
      end

      root 'pages#home'
    end
    # Match Bad Routing
    match '*not_found', :to => 'application#render_404', :via => :all
  end
end
