class Api::V1::AdvertsController < Api::V1::BaseController
  before_action :set_advert, only: [:show, :update, :destroy]

  # GET /adverts
  def index
    render json: AdvertsService.new.get_adverts(query_params)
  end

  # GET /adverts/1
  def show
    render json: AdvertsService.new.get_advert(@advert)
  end

  # POST /api/v1/adverts
  def create
    render json: AdvertsService.new.create_advert(advert_params)
  end

  # PATCH/PUT /adverts/1
  def update
    render json: AdvertsService.new.update_advert(@advert, advert_params)
  end

  # DELETE /adverts /1
  def destroy
    render json: AdvertsService.new.destroy_advert(@advert, destroy_params)
  end

  private
  def set_advert
    @advert = Advert.find_by(id: params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def advert_params
    params.require(:advert).permit( :title,
                                    :description,
                                    :status,
                                    :category,
                                    :remark,
                                    :product_ids => [])
  end

  def query_params
    params.permit(:page,
                  :per_page,
                  :status,
                  :category,
                  :product)
  end

  def destroy_params
    params.permit(:products_delete)
  end
end
