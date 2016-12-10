class Api::V1::PicturesController < Api::V1::BaseController
  before_action :set_picture, only: [:show, :update, :destroy]
  before_action :set_owner, only: [:create]

  # GET /accounts
  def index
    render json: PicturesService.new.get_pictures
  end

  # GET /accounts/1
  def show
    authorize @picture
    render json: PicturesService.new.get_picture(@picture)
  end

  # POST /accounts
  def create
    render json: PicturesService.new.create_picture(@owner, picture_params)
  end

  # PATCH/PUT /accounts/1
  def update
    authorize @picture
    render json: PicturesService.new.update_picture(@picture, picture_params)
  end

  # DELETE /accounts/1
  def destroy
    authorize @picture
    render json: PicturesService.new.destory_picture(@picture)
  end

  private

  def set_owner
    @owner = eval(params[:owner_type]).find(params[:owner_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_picture
    @picture = Picture.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def picture_params
    params.require(:picture).permit(:name, :url, :remark, :category)
  end
end
