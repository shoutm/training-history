require 'rails_helper'
require 'ostruct'

RSpec.describe SendPushNotificationJob, type: :job do
  let(:user) { User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com') }
  let(:subscription) do
    user.push_subscriptions.create!(
      endpoint: 'https://example.com/push',
      p256dh: 'key',
      auth: 'auth'
    )
  end

  describe '#perform' do
    it 'calls WebPush.payload_send with correct parameters' do
      expect(WebPush).to receive(:payload_send).with(
        hash_including(
          endpoint: subscription.endpoint,
          p256dh: subscription.p256dh,
          auth: subscription.auth
        )
      )

      described_class.perform_now(subscription.id)
    end

    it 'does nothing when subscription not found' do
      expect(WebPush).not_to receive(:payload_send)
      described_class.perform_now(999999)
    end

    it 'destroys subscription on ExpiredSubscription error' do
      sub_id = subscription.id  # Force creation before expect block
      response = OpenStruct.new(body: '')
      allow(WebPush).to receive(:payload_send).and_raise(WebPush::ExpiredSubscription.new(response, 'host'))

      expect {
        described_class.perform_now(sub_id)
      }.to change(PushSubscription, :count).by(-1)
    end

    it 'destroys subscription on InvalidSubscription error' do
      sub_id = subscription.id  # Force creation before expect block
      response = OpenStruct.new(body: '')
      allow(WebPush).to receive(:payload_send).and_raise(WebPush::InvalidSubscription.new(response, 'host'))

      expect {
        described_class.perform_now(sub_id)
      }.to change(PushSubscription, :count).by(-1)
    end

    it 'logs error on other exceptions' do
      allow(WebPush).to receive(:payload_send).and_raise(StandardError.new('Network error'))

      expect(Rails.logger).to receive(:error).with(/Push notification failed/)

      described_class.perform_now(subscription.id)
    end

    it 'sends correct message content' do
      expect(WebPush).to receive(:payload_send) do |args|
        message = JSON.parse(args[:message])
        expect(message['title']).to eq('Training History')
        expect(message['path']).to eq('/')
      end

      described_class.perform_now(subscription.id)
    end
  end
end
