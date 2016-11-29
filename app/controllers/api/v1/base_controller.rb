class Api::V1::BaseController < ApplicationController
  attr_accessor :current_user

  before_action :authenticate_user!, except: [ :index, :show, :login ]

  def authenticate_user!
    token, options = ActionController::HttpAuthentication::Token.token_and_options(request)
    mobile_number = options.blank?? nil : options[:mobile_number]
    account = mobile_number && Account.find_by(mobile_number: mobile_number)

    if account && ActiveSupport::SecurityUtils.secure_compare(account.authentication_token, token)
      self.current_user = account
    else
      return unauthenticated!
    end

  end

  def unauthenticated!
    ResponseCode.COMMON.FAILED.message = 'HTTP Token Authentication Failed!'
    render json: CommonService.response_format(ResponseCode.COMMON.FAILED)
  end

end
