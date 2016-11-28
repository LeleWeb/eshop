class Api::V1::BaseController < ApplicationController
  attr_accessor :current_user

  before_action :authenticate_user!, except: [ :index, :show ]

  def authenticate_user!
    token, options = ActionController::HttpAuthentication::Token.token_and_options(request)

    mobile_number = options.blank?? nil : options[:mobile_number]
    user = mobile_number && User.find_by(mobile_number: mobile_number)

    if user && ActiveSupport::SecurityUtils.secure_compare(user.authentication_token, token)
      self.current_user = user
    else
      return unauthenticated!
    end
  end
end
