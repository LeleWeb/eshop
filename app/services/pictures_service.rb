class PicturesService < BaseService
  def get_pictures
    CommonService.response_format(ResponseCode.COMMON.OK, Picture.all)
  end

  def get_picture(picture)
    CommonService.response_format(ResponseCode.COMMON.OK, picture)
  end

  def create_picture(owner, picture_params)
    picture = owner.pictures.create!(picture_params)
    CommonService.response_format(ResponseCode.COMMON.OK, picture)
  end

  def update_picture(picture, picture_params)
    if picture.update(picture_params)
      CommonService.response_format(ResponseCode.COMMON.OK, picture)
    else
      ResponseCode.COMMON.FAILED['message'] = picture.errors
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def destory_picture(picture)
    picture.destroy
    CommonService.response_format(ResponseCode.COMMON.OK)
  end

end