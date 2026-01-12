require 'rails_helper'

RSpec.describe PushSubscription, type: :model do
  let(:user) { User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com') }

  describe 'validations' do
    it 'is valid with all required attributes' do
      subscription = PushSubscription.new(
        user: user,
        endpoint: 'https://fcm.googleapis.com/fcm/send/abc123',
        p256dh: 'test_p256dh_key',
        auth: 'test_auth_key'
      )
      expect(subscription).to be_valid
    end

    it 'is invalid without endpoint' do
      subscription = PushSubscription.new(user: user, endpoint: nil, p256dh: 'key', auth: 'auth')
      expect(subscription).not_to be_valid
    end

    it 'is invalid without p256dh' do
      subscription = PushSubscription.new(user: user, endpoint: 'https://example.com', p256dh: nil, auth: 'auth')
      expect(subscription).not_to be_valid
    end

    it 'is invalid without auth' do
      subscription = PushSubscription.new(user: user, endpoint: 'https://example.com', p256dh: 'key', auth: nil)
      expect(subscription).not_to be_valid
    end

    it 'is invalid with duplicate endpoint' do
      PushSubscription.create!(user: user, endpoint: 'https://example.com/abc', p256dh: 'key1', auth: 'auth1')
      subscription = PushSubscription.new(user: user, endpoint: 'https://example.com/abc', p256dh: 'key2', auth: 'auth2')
      expect(subscription).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      subscription = PushSubscription.create!(
        user: user,
        endpoint: 'https://example.com',
        p256dh: 'key',
        auth: 'auth'
      )
      expect(subscription.user).to eq(user)
    end
  end
end
