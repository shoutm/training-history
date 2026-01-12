require 'rails_helper'

RSpec.describe "NotificationSettings", type: :request do
  let(:user) { User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com') }

  before do
    sign_in(user)
  end

  describe "GET /notification_settings" do
    it "returns http success" do
      get notification_settings_path
      expect(response).to have_http_status(:success)
    end

    it "creates notification settings for all days if not exist" do
      expect {
        get notification_settings_path
      }.to change(NotificationSetting, :count).by(7)
    end

    it "does not create duplicate settings" do
      user.notification_settings.create!(day_of_week: 0)
      expect {
        get notification_settings_path
      }.to change(NotificationSetting, :count).by(6)
    end

    context "without push subscription" do
      it "shows message to enable notifications first" do
        get notification_settings_path
        expect(response.body).to include("Enable push notifications")
      end
    end

    context "with push subscription" do
      before do
        user.push_subscriptions.create!(endpoint: 'https://example.com', p256dh: 'key', auth: 'auth')
      end

      it "shows the schedule form" do
        get notification_settings_path
        expect(response.body).to include("Schedule by Day")
      end

      it "shows all days of the week" do
        get notification_settings_path
        %w[日 月 火 水 木 金 土].each do |day|
          expect(response.body).to include(day)
        end
      end
    end
  end

  describe "PATCH /notification_settings/bulk_update" do
    before do
      (0..6).each do |day|
        user.notification_settings.create!(day_of_week: day, enabled: false)
      end
    end

    it "updates multiple settings at once" do
      settings = user.notification_settings.order(:day_of_week)

      patch bulk_update_notification_settings_path, params: {
        settings: {
          settings[0].id.to_s => { enabled: "1", notify_at_utc: "12:00" },
          settings[1].id.to_s => { enabled: "1", notify_at_utc: "13:00" }
        }
      }

      settings.reload
      expect(settings[0].enabled).to be true
      expect(settings[0].notify_at_utc.strftime("%H:%M")).to eq("12:00")
      expect(settings[1].enabled).to be true
      expect(settings[1].notify_at_utc.strftime("%H:%M")).to eq("13:00")
    end

    it "disables settings not included in params" do
      settings = user.notification_settings.order(:day_of_week)
      settings[0].update!(enabled: true, notify_at_utc: "12:00")

      patch bulk_update_notification_settings_path, params: {
        settings: {}
      }

      settings[0].reload
      expect(settings[0].enabled).to be false
    end

    it "redirects to index with notice" do
      patch bulk_update_notification_settings_path, params: { settings: {} }
      expect(response).to redirect_to(notification_settings_path)
      follow_redirect!
      expect(response.body).to include("Settings saved")
    end
  end

  describe "without authentication" do
    before do
      delete logout_path
    end

    it "redirects to login page" do
      get notification_settings_path
      expect(response).to redirect_to(login_path)
    end
  end
end
