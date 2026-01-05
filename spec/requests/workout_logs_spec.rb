require 'rails_helper'

RSpec.describe "WorkoutLogs", type: :request do
  let(:user) { User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com') }

  before do
    sign_in(user)
  end

  describe "GET /" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "displays the current month by default" do
      get root_path
      expect(response.body).to include(Date.current.strftime("%Y年 %m月"))
    end

    it "displays the specified month" do
      get root_path(month: "2026-02-01")
      expect(response.body).to include("2026年 02月")
    end

    it "shows workout logs for the month" do
      user.workout_logs.create!(date: Date.new(2026, 1, 15))
      get root_path(month: "2026-01-01")
      expect(response.body).to include("✅")
    end

    it "displays the training count" do
      user.workout_logs.create!(date: Date.new(2026, 1, 10))
      user.workout_logs.create!(date: Date.new(2026, 1, 20))
      get root_path(month: "2026-01-01")
      expect(response.body).to include("2")
    end

    it "only shows current user's workout logs" do
      other_user = User.create!(provider: 'google_oauth2', uid: '456', name: 'Other', email: 'other@example.com')
      other_user.workout_logs.create!(date: Date.new(2026, 1, 15))
      get root_path(month: "2026-01-01")
      expect(response.body).not_to include("✅")
    end
  end

  describe "POST /toggle/:date" do
    context "when no workout log exists for the date" do
      it "creates a new workout log" do
        expect {
          post toggle_workout_path(date: "2026-01-15")
        }.to change(user.workout_logs, :count).by(1)
      end

      it "redirects to the calendar with highlight" do
        post toggle_workout_path(date: "2026-01-15")
        expect(response).to redirect_to(root_path(month: "2026-01-01", highlight: "2026-01-15"))
      end
    end

    context "when a workout log exists for the date" do
      before do
        user.workout_logs.create!(date: Date.new(2026, 1, 15))
      end

      it "deletes the existing workout log" do
        expect {
          post toggle_workout_path(date: "2026-01-15")
        }.to change(user.workout_logs, :count).by(-1)
      end

      it "redirects to the calendar" do
        post toggle_workout_path(date: "2026-01-15")
        expect(response).to redirect_to(root_path(month: "2026-01-01"))
      end
    end
  end

  describe "without authentication" do
    before do
      # Clear session
      delete logout_path
    end

    it "redirects to login page" do
      get root_path
      expect(response).to redirect_to(login_path)
    end
  end
end
