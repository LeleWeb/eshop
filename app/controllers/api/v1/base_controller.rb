class Api::V1::BaseController < ApplicationController
  # disable the CSRF token
  protect_from_forgery with: :null_session

  # disable the CSRF token
  skip_before_action :verify_authenticity_token

  # Pundit
  include Pundit

  attr_accessor :current_user

  # 统一在此捕获Pundit异常，并处理。
  rescue_from Pundit::NotAuthorizedError, with: :deny_access

  def deny_access
    ResponseCode.COMMON.FAILED['message'] = 'NotAuthorizedError!'
    render json: CommonService.response_format(ResponseCode.COMMON.FAILED)
  end

  # API鉴权
  before_action :authenticate_user!, except: [ :index, :show, :login ]

  def authenticate_user!
    token, options = ActionController::HttpAuthentication::Token.token_and_options(request)
    p '@'*10,token,options
    mobile_number = options.blank?? nil : options[:mobile_number]
    account = mobile_number && Account.find_by(mobile_number: mobile_number)
    if account && ActiveSupport::SecurityUtils.secure_compare(account.authentication_token, token)
      self.current_user = account
    else
      return unauthenticated!
    end

  end

  def unauthenticated!
    ResponseCode.COMMON.FAILED['message'] = 'HTTP Token Authentication Failed!'
    render json: CommonService.response_format(ResponseCode.COMMON.FAILED)
  end

end
