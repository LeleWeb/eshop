class Api::V1::ProductsController < ApplicationController
  before_action :set_account, only: [:show, :update, :destroy]

  # GET /accounts
  def index
    render json: AccountsService.new.get_accounts
  end

  # GET /accounts/1
  def show
    authorize @account
    render json: AccountsService.new.get_account(@account)
  end

  # POST /accounts
  def create
    render json: AccountsService.new.create_account(account_params)
  end

  # PATCH/PUT /accounts/1
  def update
    authorize @account
    render json: AccountsService.new.update_account(@account, account_params)
  end

  # DELETE /accounts/1
  def destroy
    authorize @account
    render json: AccountsService.new.destory_account(@account)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = Account.find(@account)
  end

  # Only allow a trusted parameter "white list" through.
  def account_params
    params.require(:account).permit(:uuid, :mobile_number, :email, :password)
  end
end
