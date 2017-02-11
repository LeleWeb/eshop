class ImagesService < BaseService
  def get_images
    CommonService.response_format(ResponseCode.COMMON.OK, Image.all)
  end

  def create_image(owner, image_params)
    # 先删除该商品对应分类的所有图片
    Image.where(imageable_type: "#{owner.class.name}",
                imageable_id: owner.id,
                category: image_params[:category]).destroy_all

    # 新增改商品指定分类的图片
    image = owner.images.build(image_params)
    if image.save
      image_params[:document_data].each do |file|
        image.documents.create!(:document => file)
      end
      CommonService.response_format(ResponseCode.COMMON.OK,
                                    image.as_json.merge(:pictures => image.documents))
    else
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end
end