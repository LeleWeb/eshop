Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :accounts

      # 登陆登出
      resources :session, only: [:create, :destory]
    end
  end
end
