class Api::V1::CustomersController < Api::V1::BaseController
  before_action :set_customer, only: [:show, :update, :destroy]

  # GET /accounts
  def index
    render json: CustomersService.new.get_customers
  end

  # GET /accounts/1
  def show
    authorize @customer
    render json: CustomersService.new.get_customer(@customer)
  end

  # POST /accounts
  def create
    render json: CustomersService.new.create_customer(customer_params)
  end

  # PATCH/PUT /accounts/1
  def update
    authorize @customer
    render json: CustomersService.new.update_customer(@customer, customer_params)
  end

  # DELETE /accounts/1
  def destroy
    authorize @customer
    render json: CustomersService.new.destory_customer(@customer)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_customer
    @customer = Customer.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def customer_params
    params.require(:customer).permit(:wechat_id, :mobile_number, :nick_name, :heard_url,
                                     :real_name, :gender, :age, :address, :is_wechat_focus,
                                     :level, :integral, :remark)
  end
end
