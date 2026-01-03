require 'rails_helper'

RSpec.describe "WorkoutLogs", type: :request do
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
      WorkoutLog.create!(date: Date.new(2026, 1, 15))
      get root_path(month: "2026-01-01")
      expect(response.body).to include("✅")
    end

    it "displays the training count" do
      WorkoutLog.create!(date: Date.new(2026, 1, 10))
      WorkoutLog.create!(date: Date.new(2026, 1, 20))
      get root_path(month: "2026-01-01")
      expect(response.body).to include("2")
    end
  end

  describe "POST /toggle/:date" do
    context "when no workout log exists for the date" do
      it "creates a new workout log" do
        expect {
          post toggle_workout_path(date: "2026-01-15")
        }.to change(WorkoutLog, :count).by(1)
      end

      it "redirects to the calendar" do
        post toggle_workout_path(date: "2026-01-15")
        expect(response).to redirect_to(root_path(month: "2026-01-01"))
      end
    end

    context "when a workout log exists for the date" do
      before do
        WorkoutLog.create!(date: Date.new(2026, 1, 15))
      end

      it "deletes the existing workout log" do
        expect {
          post toggle_workout_path(date: "2026-01-15")
        }.to change(WorkoutLog, :count).by(-1)
      end

      it "redirects to the calendar" do
        post toggle_workout_path(date: "2026-01-15")
        expect(response).to redirect_to(root_path(month: "2026-01-01"))
      end
    end
  end
end
