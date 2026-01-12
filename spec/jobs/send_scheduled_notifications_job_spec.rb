require 'rails_helper'

RSpec.describe SendScheduledNotificationsJob, type: :job do
  let(:user) { User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com') }

  describe '#perform' do
    before do
      user.push_subscriptions.create!(
        endpoint: 'https://example.com/push',
        p256dh: 'key',
        auth: 'auth'
      )
    end

    it 'enqueues SendPushNotificationJob for matching settings' do
      # Create setting for current day and time
      current_time = Time.current
      user.notification_settings.create!(
        day_of_week: current_time.wday,
        enabled: true,
        notify_at_utc: current_time.strftime("%H:%M")
      )

      expect {
        described_class.perform_now
      }.to have_enqueued_job(SendPushNotificationJob)
    end

    it 'does not enqueue job for disabled settings' do
      current_time = Time.current
      user.notification_settings.create!(
        day_of_week: current_time.wday,
        enabled: false,
        notify_at_utc: current_time.strftime("%H:%M")
      )

      expect {
        described_class.perform_now
      }.not_to have_enqueued_job(SendPushNotificationJob)
    end

    it 'does not enqueue job for different day' do
      current_time = Time.current
      different_day = (current_time.wday + 1) % 7
      user.notification_settings.create!(
        day_of_week: different_day,
        enabled: true,
        notify_at_utc: current_time.strftime("%H:%M")
      )

      expect {
        described_class.perform_now
      }.not_to have_enqueued_job(SendPushNotificationJob)
    end

    it 'does not enqueue job for different time' do
      current_time = Time.current
      different_time = (current_time + 1.hour).strftime("%H:%M")
      user.notification_settings.create!(
        day_of_week: current_time.wday,
        enabled: true,
        notify_at_utc: different_time
      )

      expect {
        described_class.perform_now
      }.not_to have_enqueued_job(SendPushNotificationJob)
    end

    it 'does not enqueue job for users without push subscriptions' do
      user.push_subscriptions.destroy_all
      current_time = Time.current
      user.notification_settings.create!(
        day_of_week: current_time.wday,
        enabled: true,
        notify_at_utc: current_time.strftime("%H:%M")
      )

      expect {
        described_class.perform_now
      }.not_to have_enqueued_job(SendPushNotificationJob)
    end

    it 'enqueues job for each push subscription' do
      user.push_subscriptions.create!(
        endpoint: 'https://example.com/push2',
        p256dh: 'key2',
        auth: 'auth2'
      )

      current_time = Time.current
      user.notification_settings.create!(
        day_of_week: current_time.wday,
        enabled: true,
        notify_at_utc: current_time.strftime("%H:%M")
      )

      expect {
        described_class.perform_now
      }.to have_enqueued_job(SendPushNotificationJob).exactly(2).times
    end
  end
end
