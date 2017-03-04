class Api::V1::PanicBuyingsController < Api::V1::BaseController
  before_action :set_panic_buying, only: [:show, :update, :destroy]

  # GET /panic_buyings
  def index
    render json: PanicBuyingsService.new.get_panic_buyings(query_params)
  end

  # GET /panic_buyings/1
  def show
    render json: PanicBuyingsService.new.get_panic_buying(@panic_buying)
  end

  # POST /api/v1/panic_buyings
  def create
    render json: PanicBuyingsService.new.create_panic_buying(panic_buying_params)
  end

  # PATCH/PUT /panic_buyings/1
  def update
    render json: PanicBuyingsService.new.update_panic_buying(@panic_buying, panic_buying_params)
  end

  # DELETE /panic_buyings /1
  def destroy
    render json: PanicBuyingsService.new.destroy_panic_buying(@panic_buying, destroy_params)
  end

  private
  def set_panic_buying
    @panic_buying = PanicBuying.find_by(id: params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def panic_buying_params
    params.require(:panic_buying).permit( :begin_time,
                                          :end_time,
                                          :product_ids => [])
  end

  def query_params
    params.permit(:page,
                  :per_page)
  end

  def destroy_params
    params[:panic_buying]
  end
end
