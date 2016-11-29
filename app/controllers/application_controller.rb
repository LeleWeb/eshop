class ApplicationController < ActionController::API
  include Pundit
  protect_from_forgery
end
