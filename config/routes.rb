Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :accounts do
        resources :stores do
          resources :products
        end
        resources :customers
      end

      resources :categories
      resources :orders
      resources :pictures
      resources :carts
      resources :collections
      resources :addresses

      # 微信推送事件统一接口
      resources :wechat
      # 微信生成带参数二维码
      resources :qrcode
      # 微信支付相关接口
      resources :wxpay

      # 登陆登出
      post 'login', to: 'session#login'
      post 'logout', to: 'session#logout'
    end
  end
end
