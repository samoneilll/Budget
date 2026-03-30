Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get  "dashboard", to: "dashboard#show"
      post "jobs/categorise", to: "jobs#categorise"
      resources :fixed_expenses, only: [:index, :create, :update, :destroy]
      resources :transactions, only: [:index, :show, :update] do
        member     { post :reprocess }
        collection { post :reprocess_bulk }
      end
      post 'budget_categories/reorder', to: 'budget_categories#reorder'
      resources :budget_categories
      resources :transaction_categories, only: [:index]
      get "budget_periods/current/summary", to: "budget_periods#summary", defaults: { id: "current" }
      resources :budget_periods, only: [:index, :show] do
        member { get :summary }
        resources :savings_contributions, only: [:index], shallow: true
      end
      resources :savings_accounts do
        resources :savings_snapshots, only: [:index]
      end
      resources :mortgages, only: [:index, :show, :update] do
        resources :mortgage_snapshots, only: [:index]
        resources :lvr_milestones
      end
      resources :settings, only: [:index, :show, :update], param: :key
    end
  end
end
