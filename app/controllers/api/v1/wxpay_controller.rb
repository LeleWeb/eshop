class Api::V1::WxpayController < Api::V1::BaseController
  #before_action :wxpay_params, only: [:create]

  #
  def index
    puts 'm'*10
    p params
    render json: {status: "ok"}
  end

  #
  def create
    puts 'n'*10
    p params
    render json: {status: "ok"}
  end

  private

  # Only allow a trusted parameter "white list" through.
  def wxpay_params
    params#.permit()
  end
end
