class Api::V1::ImagesController < Api::V1::BaseController
  before_action :set_owner, only: [:create]

  # GET /images
  def index
    render json: ImagesService.new.get_images
  end

  # POST /images
  def create
    render json: PicturesService.new.create_image(@owner, image_params)
  end

  private

  def set_owner
    p params
    @owner = eval(params[:owner_type]).find(params[:owner_id])
  end

  # Only allow a trusted parameter "white list" through.
  def image_params
    params.require(:image).permit(:name, :category, :remark, :picture)
  end
end
