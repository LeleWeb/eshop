class Api::V1::AccountsController < Api::V1::BaseController
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
    render json: AccountsService.new.create_account(account_params)
  end

  # PATCH/PUT /accounts/1
  def update
    authorize Account.find(params[:id])
    render json: AccountsService.new.update_account(params[:id], account_params)
  end

  # DELETE /accounts/1
  def destroy
    render json: AccountsService.new.destory_account(params[:id])
  end

  private
  # Only allow a trusted parameter "white list" through.
  def account_params
    params.require(:account).permit(:uuid, :mobile_number, :email, :password)
  end
end
