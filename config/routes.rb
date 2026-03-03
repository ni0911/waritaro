Rails.application.routes.draw do
  root "sheets#index"

  resources :sheets, param: :year_month, only: [ :index, :create, :destroy ] do
    member do
      get  :settlement
      post :apply_template
    end
    resources :sheet_items, only: [ :create, :destroy ] do
      member do
        patch :update_burden
        patch :update_amount
      end
    end
  end

  resources :template_items, only: [ :index, :new, :create, :edit, :update, :destroy ] do
    collection do
      patch :reorder
    end
  end

  resources :cards, only: [ :index, :new, :create, :edit, :update, :destroy ]
  resource :setting, only: [ :show, :update ]

  # PWA関連（デフォルトのまま）
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
