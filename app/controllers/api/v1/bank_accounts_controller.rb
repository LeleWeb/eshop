class Api::V1::BankAccountsController < Api::V1::BaseController
  before_action :set_customer, only: [:create]

  # POST /accounts
  def create
    render json: BankAccountsService.new.create_back_account(@customer, back_account_params)
  end

  private

  def set_customer
    @customer = Customer.find(params[:customer_id])
  end

  # Only allow a trusted parameter "white list" through.
  def back_account_params
    params.require(:back_account).permit(:name, :card_number, :bank)
  end

end
