class Api::V1::SettingsController < Api::V1::BaseController
  before_action :set_setting, only: [:show, :update, :destroy]

  # GET /settings
  def index
    render json: SettingsService.new.get_settings(query_params)
  end

  # GET /settings/1
  def show
    render json: SettingsService.new.get_setting(@setting)
  end

  # POST /api/v1/settings
  def create
    render json: SettingsService.new.create_setting(setting_params)
  end

  # PATCH/PUT /settings/1
  def update
    render json: SettingsService.new.update_setting(setting_params)
  end

  # DELETE /settings /1
  def destroy
    render json: SettingsService.new.destroy_setting(@setting, destroy_params)
  end

  private
  def set_setting
    @setting = Setting.find_by(id: params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def setting_params
    params.require(:setting).permit( :setting_type,
                                     :data => [:category,
                                               :products => []])
  end

  def query_params
    params.permit(:page,
                  :per_page)
  end

end
