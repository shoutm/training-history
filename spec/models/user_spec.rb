require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with all required attributes' do
      user = User.new(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com')
      expect(user).to be_valid
    end

    it 'is invalid without provider' do
      user = User.new(provider: nil, uid: '123', name: 'Test', email: 'test@example.com')
      expect(user).not_to be_valid
    end

    it 'is invalid without uid' do
      user = User.new(provider: 'google_oauth2', uid: nil, name: 'Test', email: 'test@example.com')
      expect(user).not_to be_valid
    end

    it 'is invalid with duplicate provider and uid' do
      User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com')
      user = User.new(provider: 'google_oauth2', uid: '123', name: 'Test2', email: 'test2@example.com')
      expect(user).not_to be_valid
    end
  end

  describe '.find_or_create_from_omniauth' do
    let(:auth_hash) do
      OmniAuth::AuthHash.new({
        provider: 'google_oauth2',
        uid: '123456',
        info: {
          name: 'Test User',
          email: 'test@example.com',
          image: 'https://example.com/avatar.jpg'
        }
      })
    end

    it 'creates a new user when not exists' do
      expect {
        User.find_or_create_from_omniauth(auth_hash)
      }.to change(User, :count).by(1)
    end

    it 'returns existing user when already exists' do
      User.create!(provider: 'google_oauth2', uid: '123456', name: 'Old Name', email: 'old@example.com')
      expect {
        User.find_or_create_from_omniauth(auth_hash)
      }.not_to change(User, :count)
    end

    it 'sets user attributes from auth hash' do
      user = User.find_or_create_from_omniauth(auth_hash)
      expect(user.name).to eq('Test User')
      expect(user.email).to eq('test@example.com')
      expect(user.avatar_url).to eq('https://example.com/avatar.jpg')
    end
  end

  describe 'associations' do
    it 'has many workout_logs' do
      user = User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com')
      user.workout_logs.create!(date: Date.current)
      expect(user.workout_logs.count).to eq(1)
    end

    it 'destroys workout_logs when user is destroyed' do
      user = User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com')
      user.workout_logs.create!(date: Date.current)
      expect { user.destroy }.to change(WorkoutLog, :count).by(-1)
    end
  end
end
