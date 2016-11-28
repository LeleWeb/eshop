class Api::V1::SessionController < ApplicationController
  # POST /session
  def login
    cookies[:sid] = 'zhangweiid'
    puts cookies[:sid]
    render json: SessionService.new.login(session_params)
  end

  # DELETE /session
  def logout
    puts cookies[:sid]
    render json: SessionService.new.logout(session[:sid])
  end

  private
  # Only allow a trusted parameter "white list" through.
  def session_params
    params.permit(:username, :password)
  end
end
