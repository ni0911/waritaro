Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  # ユーザー登録
  get  "register",  to: "registrations#new",    as: :new_registration
  post "register",  to: "registrations#create", as: :registrations

  # グループ作成・参加
  resource :setting, only: [ :show, :update ] do
    get  :new_group,    on: :member
    post :create_group, on: :member
    get  :join,         on: :member
    post :join,         on: :member
  end

  root "sheets#index"

  resources :sheets, param: :year_month, only: [ :index, :create, :destroy ] do
    member do
      get  :settlement
      post :apply_template
    end
    resources :sheet_items, only: [ :create, :destroy, :edit, :update ] do
      member do
        get   :cancel
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

  # PWA関連（デフォルトのまま）
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
