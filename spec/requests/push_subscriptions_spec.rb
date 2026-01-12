require 'rails_helper'

RSpec.describe "PushSubscriptions", type: :request do
  let(:user) { User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com') }

  before do
    sign_in(user)
  end

  describe "POST /push_subscriptions" do
    let(:valid_params) do
      {
        endpoint: 'https://fcm.googleapis.com/fcm/send/abc123',
        p256dh: 'test_p256dh_key',
        auth: 'test_auth_key'
      }
    end

    it "creates a new push subscription" do
      expect {
        post push_subscriptions_path, params: valid_params, as: :json
      }.to change(PushSubscription, :count).by(1)
    end

    it "returns success response" do
      post push_subscriptions_path, params: valid_params, as: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["success"]).to be true
    end

    it "updates existing subscription with same endpoint" do
      user.push_subscriptions.create!(endpoint: valid_params[:endpoint], p256dh: 'old_key', auth: 'old_auth')

      expect {
        post push_subscriptions_path, params: valid_params, as: :json
      }.not_to change(PushSubscription, :count)

      subscription = user.push_subscriptions.first
      expect(subscription.p256dh).to eq('test_p256dh_key')
      expect(subscription.auth).to eq('test_auth_key')
    end

    it "returns error for invalid params" do
      post push_subscriptions_path, params: { endpoint: '' }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /push_subscriptions" do
    it "destroys the subscription" do
      subscription = user.push_subscriptions.create!(
        endpoint: 'https://example.com/abc',
        p256dh: 'key',
        auth: 'auth'
      )

      expect {
        delete push_subscriptions_path, params: { endpoint: subscription.endpoint }, as: :json
      }.to change(PushSubscription, :count).by(-1)
    end

    it "returns success even if subscription not found" do
      delete push_subscriptions_path, params: { endpoint: 'nonexistent' }, as: :json
      expect(response).to have_http_status(:success)
    end

    it "only deletes current user's subscription" do
      other_user = User.create!(provider: 'google_oauth2', uid: '456', name: 'Other', email: 'other@example.com')
      subscription = other_user.push_subscriptions.create!(
        endpoint: 'https://example.com/other',
        p256dh: 'key',
        auth: 'auth'
      )

      expect {
        delete push_subscriptions_path, params: { endpoint: subscription.endpoint }, as: :json
      }.not_to change(PushSubscription, :count)
    end
  end

  describe "without authentication" do
    before do
      delete logout_path
    end

    it "redirects to login page for create" do
      post push_subscriptions_path, params: { endpoint: 'test' }, as: :json
      expect(response).to redirect_to(login_path)
    end
  end
end
