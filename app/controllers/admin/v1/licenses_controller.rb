class Admin::V1::LicensesController < Admin::V1::ApiController
  before_action :load_license, only: [:update, :destroy, :show]

  def index
    game_license = License.where(game_id: params[:game_id])
    @loading_service = Admin::ModelLoadingService.new(game_license, searchable_params)
    @loading_service.execute
  end

  def create
    @license = License.new(game_id: params[:game_id])
    @license.attributes = license_params
    save_license!
  end

  def show; end

  def update
    @license.attributes = license_params
    save_license!
  end

  def destroy
    @license.destroy!
  rescue
    render_error(fields: @license.errors.messages)
  end

  private

  def load_license
    @license = License.find(params[:id])
  end

  def searchable_params
    params.permit({ search: :key }, { order: {} }, :page, :length)
  end

  def license_params
    return {} unless params.has_key?(:license)

    params.require(:license).permit(:key, :status, :platform)
  end

  def save_license!
    @license.save!
    render :show
  rescue
    render_error(fields: @license.errors.messages)
  end
end
