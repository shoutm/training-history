class SendPushNotificationJob < ApplicationJob
  queue_as :default

  def perform(push_subscription_id)
    subscription = PushSubscription.find_by(id: push_subscription_id)
    return unless subscription

    message = {
      title: "Training History",
      body: "トレーニングの時間です!",
      path: "/"
    }

    WebPush.payload_send(
      message: message.to_json,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh,
      auth: subscription.auth,
      vapid: {
        subject: "mailto:training@example.com",
        public_key: Rails.application.credentials.dig(:vapid, :public_key),
        private_key: Rails.application.credentials.dig(:vapid, :private_key)
      }
    )
  rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
    subscription.destroy
  rescue => e
    Rails.logger.error "Push notification failed: #{e.message}"
  end
end
