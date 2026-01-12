class RenameNotifyAtToNotifyAtUtcInNotificationSettings < ActiveRecord::Migration[8.1]
  def change
    rename_column :notification_settings, :notify_at, :notify_at_utc
  end
end
