class Api::V1::CategoriesController < Api::V1::BaseController
  before_action :set_category, only: [:show, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:create]

  # GET /categories
  def index
    render json: CategoriesService.new.get_categories
  end

  # GET /categories /1
  def show
    authorize @category
    render json: CategoriesService.new.get_category(@category)
  end

  # POST /api/v1/categories
  def create
    render json: CategoriesService.new.create_category(category_params)
  end

  # PATCH/PUT /categories /1
  def update
    authorize @category
    render json: CategoriesService.new.update_category(@category, category_params)
  end

  # DELETE /categories /1
  def destroy
    authorize @category
    render json: CategoriesService.new.destory_category(@category)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_category
    @category = Category.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def category_params
    params.require(:category).permit(:name, :type, :parent_id)
  end

end
