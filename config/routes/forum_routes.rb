Avicus::Application.routes.draw do
  scope :forums, :module => :forums do
    get '' => 'index#index', :as => 'forums'

    post 'mark_all_read' => 'index#mark_all_read', :as => 'mark_all_read'
    get 'my_discussions' => 'index#my_discussions', :as => 'my_discussions'
    get 'my_subscriptions' => 'index#my_subscriptions', :as => 'my_subscriptions'
    get 'search' => 'index#search', :as => 'forums_search'

    # LEGACY
    get ':id' => 'discussions#show'

    resources :categories do
      post 'mass_moderate' => 'categories#mass_moderate', as: 'mass_moderate'
    end

    resources :discussions do
      collection do
        post 'preview' => 'discussions#preview'
        get ':id/reply' => 'discussions#reply'
        get ':id/revisions' => 'discussions#revisions'
        post ':id/subscribe' => 'discussions#subscribe'
      end
    end

    scope 'replies' do
      # needed for "form_for'
      get '' => 'replies#index', :as => 'replies'
      post '' => 'replies#create'
      patch ':id' => 'replies#update'
      put ':id' => 'replies#update'

      get ':id/revisions' => 'replies#revisions', :as => 'reply_revisions'
      get ':id/edit' => 'replies#edit', :as => 'edit_reply'
      get 'new' => 'replies#new', :as => 'new_reply'
      get ':id' => 'replies#show', :as => 'reply'
    end
  end
end
