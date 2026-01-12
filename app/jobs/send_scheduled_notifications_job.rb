class SendScheduledNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    current_time = Time.current
    current_day = current_time.wday
    current_hour_minute = current_time.strftime("%H:%M")

    NotificationSetting
      .enabled
      .for_day(current_day)
      .includes(user: :push_subscriptions)
      .find_each do |setting|
        next unless setting.notify_at_utc&.strftime("%H:%M") == current_hour_minute
        next if setting.user.push_subscriptions.empty?

        setting.user.push_subscriptions.each do |subscription|
          SendPushNotificationJob.perform_later(subscription.id)
        end
      end
  end
end
