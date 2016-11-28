class Api::V1::SessionController < Api::V1::BaseController
  # POST /session
  def login
    render json: SessionService.new.login(session_params)
  end

  # DELETE /session
  def logout
    render json: SessionService.new.logout
  end

  private
  # Only allow a trusted parameter "white list" through.
  def session_params
    params.permit(:username, :password)
  end
end
