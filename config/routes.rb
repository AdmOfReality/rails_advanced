Rails.application.routes.draw do
  root to: 'questions#index'

  devise_for :users
  resources :questions do
    delete :purge_attachment, on: :member
    resources :answers, shallow: true, only: %i[create destroy update] do
      patch :best, on: :member
      delete :purge_attachment, on: :member
    end
  end
end
