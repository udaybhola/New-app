class Admin::MobileAppSettingsController < ApplicationController
  before_action :authenticate_admin!
  layout 'admin'

  def index
    @settings = MobileAppSetting.all
  end

  def edit
    @setting = MobileAppSetting.find(params.permit(:id)[:id])
  end

  def update
    @setting = MobileAppSetting.find(params.permit(:id)[:id])

    if @setting.update_attributes(settings_params)
      redirect_to admin_path
    else
      render action: :edit
    end
  end

  private

  def settings_params
    params.require(:mobile_app_setting).permit(:dashboard_state_candidature_count, :voting_booth_mla_candidature_count, :voting_booth_mp_candidature_count, :dashboard_national_candidature_count)
  end
end
