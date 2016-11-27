class Api::V1::AccountsController < ApplicationController
  before_action :set_account, only: [:show, :update, :destroy]

  # GET /accounts
  def index
    render json: AccountsService.new.get_accounts
  end

  # GET /accounts/1
  def show
    render json: AccountsService.new.get_account(params[:id])
  end

  # POST /accounts
  def create
    # @account = Account.new(account_params)
    #
    # if @account.save
    #   render json: @account, status: :created, location: @account
    # else
    #   render json: @account.errors, status: :unprocessable_entity
    # end
    render json: AccountsService.new.create_account(account_params)
  end

  # PATCH/PUT /accounts/1
  def update
    # if @account.update(account_params)
    #   render json: @account
    # else
    #   render json: @account.errors, status: :unprocessable_entity
    # end
    render json: AccountsService.new.update_account(account_params)
  end

  # DELETE /accounts/1
  def destroy
    @account.destroy
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_account
    @account = Account.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def account_params
    params.fetch(:account, {})
  end
end
