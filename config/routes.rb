Rails.application.routes.draw do
  root to: 'questions#index'

  devise_for :users
  resources :questions do
    delete :purge_attachment, on: :member
    delete 'question_links/:link_id', to: 'questions#destroy_link', on: :member, as: :destroy_link
    resources :answers, shallow: true, only: %i[create destroy update] do
      patch :best, on: :member
      delete :purge_attachment, on: :member
      delete 'answer_links/:link_id', to: 'answers#destroy_link', on: :member, as: :destroy_link
    end
  end
end
