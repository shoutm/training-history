require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /login" do
    it "returns http success" do
      get login_path
      expect(response).to have_http_status(:success)
    end

    it "displays the login page" do
      get login_path
      expect(response.body).to include("Sign in with Google")
    end

    it "redirects to root if already logged in" do
      user = User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com')
      sign_in(user)
      get login_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /auth/google_oauth2/callback" do
    before do
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
        provider: 'google_oauth2',
        uid: '123456',
        info: {
          name: 'Test User',
          email: 'test@example.com',
          image: 'https://example.com/avatar.jpg'
        }
      })
    end

    it "creates a new user" do
      expect {
        get "/auth/google_oauth2/callback"
      }.to change(User, :count).by(1)
    end

    it "redirects to root path" do
      get "/auth/google_oauth2/callback"
      expect(response).to redirect_to(root_path)
    end

    it "sets the session" do
      get "/auth/google_oauth2/callback"
      follow_redirect!
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /logout" do
    let(:user) { User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com') }

    before do
      sign_in(user)
    end

    it "clears the session" do
      delete logout_path
      expect(response).to redirect_to(login_path)
    end

    it "redirects unauthenticated requests to login" do
      delete logout_path
      get root_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe "GET /auth/failure" do
    it "redirects to login with error message" do
      get "/auth/failure", params: { message: "access_denied" }
      expect(response).to redirect_to(login_path)
    end
  end
end
