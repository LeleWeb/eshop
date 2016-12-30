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
      # 微信网页授权回调接口
      resources :wx_page_authorization
      # 创建分销二维码接口
      resources :distribution_qrcode

      # 分销关系接口
      # namespace :distributions do
        # 查询分销佣金总额接口
        get '/distributions/commission', to: 'distributions#get_commission'
        get '/distributions/authority', to: 'distributions#get_distribute_authority'
      # end
      resources :distributions

      # 公众号创建菜单接口
      resources :wxmenu

      # 用户银行账号接口
      resources :bank_accounts

      # 体现明细接口
      resources :withdraw_details

      # 登陆登出
      post 'login', to: 'session#login'
      post 'logout', to: 'session#logout'
    end
  end
end
