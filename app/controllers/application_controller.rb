class ApplicationController < ActionController::API
  # # Prevent CSRF attacks by raising an exception.
  # # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  # disable the CSRF token
  protect_from_forgery with: :null_session

  # disable the CSRF token
  skip_before_action :verify_authenticity_token
end
