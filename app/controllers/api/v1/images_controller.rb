class Api::V1::ImagesController < Api::V1::BaseController
  before_action :set_owner, only: [:create]

  # GET /images
  def index
    @images = ImagesService.new.get_images
  end

  # POST /images
  def create
    @res = PicturesService.new.create_picture(@owner, picture_params)
  end

  private

  def set_owner
    @owner = eval(params[:owner_type]).find(params[:owner_id])
  end

  # Only allow a trusted parameter "white list" through.
  def image_params
    params.require(:image).permit(:name, :category, :remark, :picture)
  end
end
