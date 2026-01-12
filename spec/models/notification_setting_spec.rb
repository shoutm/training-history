require 'rails_helper'

RSpec.describe NotificationSetting, type: :model do
  let(:user) { User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com') }

  describe 'validations' do
    it 'is valid with all required attributes' do
      setting = NotificationSetting.new(user: user, day_of_week: 0, enabled: false)
      expect(setting).to be_valid
    end

    it 'is invalid without day_of_week' do
      setting = NotificationSetting.new(user: user, day_of_week: nil)
      expect(setting).not_to be_valid
    end

    it 'is invalid with day_of_week outside 0-6' do
      setting = NotificationSetting.new(user: user, day_of_week: 7)
      expect(setting).not_to be_valid
    end

    it 'is invalid with duplicate user_id and day_of_week' do
      NotificationSetting.create!(user: user, day_of_week: 0)
      setting = NotificationSetting.new(user: user, day_of_week: 0)
      expect(setting).not_to be_valid
    end

    it 'requires notify_at_utc when enabled' do
      setting = NotificationSetting.new(user: user, day_of_week: 0, enabled: true, notify_at_utc: nil)
      expect(setting).not_to be_valid
    end

    it 'does not require notify_at_utc when disabled' do
      setting = NotificationSetting.new(user: user, day_of_week: 0, enabled: false, notify_at_utc: nil)
      expect(setting).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      setting = NotificationSetting.create!(user: user, day_of_week: 0)
      expect(setting.user).to eq(user)
    end
  end

  describe 'scopes' do
    before do
      NotificationSetting.create!(user: user, day_of_week: 0, enabled: true, notify_at_utc: '12:00')
      NotificationSetting.create!(user: user, day_of_week: 1, enabled: false)
      NotificationSetting.create!(user: user, day_of_week: 2, enabled: true, notify_at_utc: '13:00')
    end

    it '.enabled returns only enabled settings' do
      expect(NotificationSetting.enabled.count).to eq(2)
    end

    it '.for_day returns settings for specific day' do
      expect(NotificationSetting.for_day(0).count).to eq(1)
      expect(NotificationSetting.for_day(0).first.day_of_week).to eq(0)
    end
  end

  describe '#day_name' do
    it 'returns Japanese day name' do
      expect(NotificationSetting.new(day_of_week: 0).day_name).to eq('日')
      expect(NotificationSetting.new(day_of_week: 1).day_name).to eq('月')
      expect(NotificationSetting.new(day_of_week: 6).day_name).to eq('土')
    end
  end
end
