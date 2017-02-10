class ImagesService < BaseService
  def get_images
    CommonService.response_format(ResponseCode.COMMON.OK, Image.all)
  end

  def create_image(owner, image_params)
    image = owner.images.create!(image_params)
    CommonService.response_format(ResponseCode.COMMON.OK, image)
  end

end