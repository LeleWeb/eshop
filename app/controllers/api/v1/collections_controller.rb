class Api::V1::CollectionsController < Api::V1::BaseController
  before_action :set_collection, only: [:show, :update, :destroy]
  before_action :set_owner, only: [:index, :create]
  before_action :set_object, only: [:create]

  # GET /accounts
  def index
    render json: CollectionsService.new.get_collections(@owner)
  end

  # GET /accounts/1
  def show
    authorize @collection
    render json: CollectionsService.new.get_collection(@collection)
  end

  # POST /accounts
  def create
    render json: CollectionsService.new.create_collection(@owner, @object, collection_params)
  end

  # PATCH/PUT /accounts/1
  def update
    authorize @collection
    render json: CollectionsService.new.update_collection(@collection, collection_params)
  end

  # DELETE /accounts/1
  def destroy
    authorize @collection
    render json: CollectionsService.new.destory_collection(@collection)
  end

  private

  def set_object
    @object = eval(params[:object_type]).find(params[:object_id])
  end

  def set_owner
    @owner = eval(params[:owner_type]).find(params[:owner_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_collection
    @collection = Collection.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def collection_params
    params.require(:collection).permit(:amount, :remark)
  end

end
