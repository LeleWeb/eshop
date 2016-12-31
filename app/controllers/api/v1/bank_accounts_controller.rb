class Api::V1::BankAccountsController < Api::V1::BaseController
  before_action :set_bank_account, only: [:show, :update, :destroy]
  before_action :set_customer, only: [:create, :index]

  # GET /bank_accounts
  def index
    render json: BankAccountsService.new.get_bank_accounts(@customer)
  end

  # GET /bank_accounts/1
  def show
    render json: BankAccountsService.new.get_bank_account(@bank_account)
  end

  # POST /bank_accounts
  def create
    render json: BankAccountsService.new.create_bank_account(@customer, bank_account_params)
  end

  # PATCH/PUT /bank_accounts/1
  def update
    render json: BankAccountsService.new.update_bank_account(@bank_account, bank_account_params)
  end

  # DELETE /bank_accounts /1
  def destroy
    render json: BankAccountsService.new.destory_bank_account(@bank_account)
  end

  private

  def set_bank_account
    @bank_account = BankAccount.find(params[:id])
  end

  def set_customer
    @customer = Customer.find(params[:customer_id])
  end

  # Only allow a trusted parameter "white list" through.
  def bank_account_params
    params["bank_account"]#.require(:bank_account)#.permit(:name, :card_number, :bank, :is_default)
  end

end
