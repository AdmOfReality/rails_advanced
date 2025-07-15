Rails.application.routes.draw do
  use_doorkeeper
  resources :rewards, only: [:index]

  root to: 'questions#index'

  devise_for :users, controllers: {
    omniauth_callbacks: 'oauth_callbacks',
    confirmations: 'confirmations'
  }

  resource :oauth_email, only: [:new, :create], controller: 'oauth_emails'

  resources :questions do
    resources :comments, only: :create
    member do
      delete :purge_attachment
      delete 'question_links/:link_id', to: 'questions#destroy_link', as: :destroy_link
    end

    resources :answers, shallow: true, only: %i[create destroy update] do
      resources :comments, only: :create
      member do
        patch :best
        delete :purge_attachment
        delete 'answer_links/:link_id', to: 'answers#destroy_link', as: :destroy_link
      end
    end
  end

  resource :votes, only: [] do
    collection do
      post 'upvote'
      post 'downvote'
      delete 'cancel'
    end
  end

  namespace :api do
    namespace :v1 do
      resources :profiles, only: [] do
        get :me, on: :collection
      end

      resources :questions, only: :index
    end
  end

  mount ActionCable.server => '/cable'
end
