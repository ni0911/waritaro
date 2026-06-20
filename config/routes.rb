Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  # ユーザー登録
  get  "register", to: "registrations#new",    as: :new_registration
  post "register", to: "registrations#create", as: :registrations

  root "home#index"

  # 招待コードでグループに参加
  resource :membership, only: %i[ new create ]

  resources :groups, only: %i[ new create show ] do
    member do
      get :invite
      get :share # グループ精算プランの LINE 共有
    end
    resources :expenses, only: %i[ new create destroy ], module: :groups
    resource  :settlement, only: %i[ create ], module: :groups # 精算を確定（スナップショット化）
  end

  # PWA関連（デフォルトのまま）
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
