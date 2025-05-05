Rails.application.routes.draw do
  resources :rewards, only: [:index]

  root to: 'questions#index'

  devise_for :users

  resources :questions do
    member do
      delete :purge_attachment
      delete 'question_links/:link_id', to: 'questions#destroy_link', as: :destroy_link
    end

    resources :answers, shallow: true, only: %i[create destroy update] do
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
end
