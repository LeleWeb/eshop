class ImagesService < BaseService
  def get_images
    CommonService.response_format(ResponseCode.COMMON.OK, Image.all)
  end

  def create_image(owner, image_params)
    # image = owner.images.create!(image_params)
    # CommonService.response_format(ResponseCode.COMMON.OK, image)

    image = owner.images.build(image_params)
    p '1'*10,image_params
    if image.save
      #iterate through each of the files
      image_params[:document_data].each do |file|
        image.documents.create!(:document => file)
        #create a document associated with the item that has just been created
      end
      CommonService.response_format(ResponseCode.COMMON.OK,
                                    image.as_json.merge(:pictures => image.documents))
    else
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

  def upload_multiple_files(owner, image_params)
    image = owner.images.build(image_params)
    if image.save
      #iterate through each of the files
      image_params[:document_data].each do |file|
        image.documents.create!(:document => file)
        #create a document associated with the item that has just been created
      end
      CommonService.response_format(ResponseCode.COMMON.OK, image.as_json.merge(:documents => image.documents))
    else
      CommonService.response_format(ResponseCode.COMMON.FAILED)
    end
  end

end