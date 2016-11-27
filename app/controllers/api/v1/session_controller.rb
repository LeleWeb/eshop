class Api::V1::SessionController < ApplicationController
  # POST /session
  def create
    render json: AccountsService.new.create_account(account_params)
  end

  # DELETE /session
  def destroy
    render json: AccountsService.new.destory_account(params[:id])
  end
end
