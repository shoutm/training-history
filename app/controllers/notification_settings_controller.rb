class NotificationSettingsController < ApplicationController
  def index
    @notification_settings = current_user.notification_settings.order(:day_of_week)
    @has_subscription = current_user.push_subscriptions.exists?

    # Initialize settings for all days if not exist
    (0..6).each do |day|
      current_user.notification_settings.find_or_create_by(day_of_week: day) do |setting|
        setting.notify_at_utc = Time.zone.parse("07:00")
        setting.enabled = false
      end
    end
    @notification_settings = current_user.notification_settings.order(:day_of_week)
  end

  def bulk_update
    settings_params = params[:settings] || {}

    current_user.notification_settings.each do |setting|
      setting_data = settings_params[setting.id.to_s]
      if setting_data
        setting.update(
          enabled: setting_data[:enabled] == "1",
          notify_at_utc: setting_data[:notify_at_utc]
        )
      else
        # Checkbox unchecked = not in params
        setting.update(enabled: false)
      end
    end

    redirect_to notification_settings_path, notice: "Settings saved"
  end
end
