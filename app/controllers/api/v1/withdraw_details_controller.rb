class Api::V1::WithdrawDetailsController < Api::V1::BaseController
  before_action :set_withdraw_detail, only: [:show, :update, :destroy]
  before_action :set_customer, only: [:create, :index]
  before_action :set_store, only: [:create]

  # GET /withdraw_details
  def index
    render json: WithdrawDetailsService.new.get_withdraw_details(@customer)
  end

  # GET /withdraw_details/1
  def show
    render json: WithdrawDetailsService.new.get_withdraw_detail(@withdraw_detail)
  end

  # POST /withdraw_details
  def create
    render json: WithdrawDetailsService.new.create_withdraw_detail(@customer, @store, withdraw_detail_params)
  end

  # # PATCH/PUT /withdraw_details/1
  # def update
  #   render json: WithdrawDetailsService.new.update_withdraw_detail(@withdraw_detail, withdraw_detail_params)
  # end

  # DELETE /withdraw_details /1
  def destroy
    render json: WithdrawDetailsService.new.destory_withdraw_detail(@withdraw_detail)
  end

  private

  def set_store
    @store = Store.find(params[:store_id])
  end

  def set_withdraw_detail
    @withdraw_detail = WithdrawDetail.find(params[:id])
  end

  def set_customer
    @customer = Customer.find(params[:customer_id])
  end

  # Only allow a trusted parameter "white list" through.
  def withdraw_detail_params
    params.require(:withdraw_detail).permit(:sum)
  end

end
