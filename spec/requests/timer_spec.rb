require 'rails_helper'

RSpec.describe "Timer", type: :request do
  let(:user) { User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com') }

  before do
    sign_in(user)
  end

  describe "GET /timer" do
    it "returns http success" do
      get timer_path
      expect(response).to have_http_status(:success)
    end

    it "displays the timer page" do
      get timer_path
      expect(response.body).to include("Interval Timer")
    end

    it "includes the Stimulus controller" do
      get timer_path
      expect(response.body).to include('data-controller="timer"')
    end

    it "has default timer values" do
      get timer_path
      expect(response.body).to include('data-timer-exercise-seconds-value="30"')
      expect(response.body).to include('data-timer-rest-seconds-value="15"')
      expect(response.body).to include('data-timer-total-sets-value="5"')
    end

    it "has control buttons" do
      get timer_path
      expect(response.body).to include("Start")
      expect(response.body).to include("Pause")
      expect(response.body).to include("Reset")
    end

    it "has settings inputs" do
      get timer_path
      expect(response.body).to include("Exercise (sec)")
      expect(response.body).to include("Rest (sec)")
      expect(response.body).to include("Sets")
    end

    it "has a link back to the calendar" do
      get timer_path
      expect(response.body).to include('href="/"')
    end
  end

  describe "without authentication" do
    before do
      delete logout_path
    end

    it "redirects to login page" do
      get timer_path
      expect(response).to redirect_to(login_path)
    end
  end
end
