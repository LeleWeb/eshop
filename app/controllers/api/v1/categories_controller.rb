class Api::V1::CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :update, :destroy]

  # GET /categories
  def index
    render json: AccountsService.new.get_categories
  end

  # GET /categories /1
  def show
    authorize @category
    render json: AccountsService.new.get_category(@category)
  end

  # POST /api/v1/categories
  def create
    render json: CategoriesService.new.create_category(category_params)
  end

  # PATCH/PUT /categories /1
  def update
    authorize @category
    render json: AccountsService.new.update_category(@category, category_params)
  end

  # DELETE /categories /1
  def destroy
    authorize @category
    render json: AccountsService.new.destory_category(@category)
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_category
    @category = Account.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def category_params
    params.require(:category).permit(:name)
  end

end
