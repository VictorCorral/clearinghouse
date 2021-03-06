class ApplicationSettingsController < ApplicationController
  before_filter :admins_only
  
  def index
  end

  def edit
    @settings = ApplicationSetting.all
  end

  def update
    respond_to do |format|
      if ApplicationSetting.update_settings(application_setting_params)
        format.html { redirect_to application_settings_path, notice: 'Application settings were successfully updated.' }
        format.json { head :no_content }
      else
        @settings = ApplicationSetting.all.merge(params[:application_setting])
        format.html { render action: :edit }
        format.json { render json: ApplicationSetting.all, status: :unprocessable_entity }
      end
    end
  end

  private

  def application_setting_params
    timeout_param = params[:application_setting].try(:[], 'devise.timeout_in')
    if timeout_param && (timeout_param.is_a?(Fixnum) || timeout_param.is_a?(Integer))
      params[:application_setting]['devise.timeout_in'] = timeout_param.minutes
    end
    params.require(:application_setting).permit!
  end
end
