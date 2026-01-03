module AuthHelpers
  def sign_in(user)
    # Set OmniAuth mock
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: user.provider,
      uid: user.uid,
      info: {
        name: user.name,
        email: user.email,
        image: user.avatar_url
      }
    })

    # Trigger the callback to set session
    get "/auth/google_oauth2/callback"
  end

  def sign_in_as_new_user
    user = User.create!(
      provider: "google_oauth2",
      uid: "123456",
      name: "Test User",
      email: "test@example.com"
    )
    sign_in(user)
    user
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
