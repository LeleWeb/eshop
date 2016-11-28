class Api::V1::BaseController < ApplicationController
  attr_accessor :current_user

  before_action :authenticate_user!, except: [ :index, :show, :login ]

  def authenticate_user!
    token, options = ActionController::HttpAuthentication::Token.token_and_options(request)
    p token, options
    mobile_number = options.blank?? nil : options[:mobile_number]
    account = mobile_number && Account.find_by(mobile_number: mobile_number)
p token, account.authentication_token
    if account && ActiveSupport::SecurityUtils.secure_compare(account.authentication_token, token)
      self.current_user = user
    else
      return unauthenticated!
    end
  end
end
