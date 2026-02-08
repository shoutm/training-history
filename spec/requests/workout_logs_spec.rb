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
      expect(response.body).to include("bg-green-600")
      expect(response.body).to include("rounded-full")
    end

    it "displays the training count" do
      user.workout_logs.create!(date: Date.new(2026, 1, 10))
      user.workout_logs.create!(date: Date.new(2026, 1, 20))
      get root_path(month: "2026-01-01")
      expect(response.body).to include("2")
    end

    it "includes swipe controller data attributes" do
      get root_path(month: "2026-03-01")
      expect(response.body).to include('data-controller="swipe"')
      expect(response.body).to include("data-swipe-prev-url-value")
      expect(response.body).to include("data-swipe-next-url-value")
      expect(response.body).to include("month=2026-02-01")
      expect(response.body).to include("month=2026-04-01")
    end

    it "only shows current user's workout logs" do
      other_user = User.create!(provider: 'google_oauth2', uid: '456', name: 'Other', email: 'other@example.com')
      other_user.workout_logs.create!(date: Date.new(2026, 1, 15))
      get root_path(month: "2026-01-01")
      expect(response.body).not_to include("absolute top-1 right-1")
    end
  end

  describe "POST /workout_logs/record" do
    let(:exercise_set) { user.exercise_sets.create!(name: "Test Set", rounds: 3) }

    it "creates a new workout log with exercise_set" do
      expect {
        post record_workout_path, params: { date: "2026-01-15", exercise_set_id: exercise_set.id }
      }.to change(user.workout_logs, :count).by(1)
    end

    it "sets the exercise_set_id" do
      post record_workout_path, params: { date: "2026-01-15", exercise_set_id: exercise_set.id }
      workout_log = user.workout_logs.last
      expect(workout_log.exercise_set_id).to eq(exercise_set.id)
    end

    it "redirects to the calendar with highlight" do
      post record_workout_path, params: { date: "2026-01-15", exercise_set_id: exercise_set.id }
      expect(response).to redirect_to(root_path(month: "2026-01-01", highlight: "2026-01-15"))
    end
  end

  describe "GET /workout_logs/:date" do
    let(:date) { Date.new(2026, 1, 15) }
    let!(:exercise_set) do
      set = user.exercise_sets.create!(name: "Morning Routine", rounds: 2)
      set.exercise_items.create!(name: "Push-ups", exercise_seconds: 30, rest_seconds: 15, position: 0)
      set.exercise_items.create!(name: "Squats", exercise_seconds: 40, rest_seconds: 20, position: 1)
      set
    end

    context "with workout logs for the date" do
      let!(:workout_log1) do
        user.workout_logs.create!(date: date, exercise_set: exercise_set)
      end
      let!(:workout_log2) do
        other_set = user.exercise_sets.create!(name: "Evening Routine", rounds: 1)
        other_set.exercise_items.create!(name: "Plank", exercise_seconds: 60, rest_seconds: 0, position: 0)
        user.workout_logs.create!(date: date, exercise_set: other_set)
      end

      it "returns http success" do
        get workout_log_date_path(date)
        expect(response).to have_http_status(:success)
      end

      it "displays the date" do
        get workout_log_date_path(date)
        expect(response.body).to include("2026年 01月 15日")
      end

      it "displays all workout logs for the date" do
        get workout_log_date_path(date)
        expect(response.body).to include("Morning Routine")
        expect(response.body).to include("Evening Routine")
      end

      it "displays exercise details" do
        get workout_log_date_path(date)
        expect(response.body).to include("Push-ups")
        expect(response.body).to include("Squats")
        expect(response.body).to include("2 rounds")
      end
    end

    context "without workout logs for the date" do
      it "displays empty state" do
        get workout_log_date_path(date)
        expect(response.body).to include("この日のトレーニング記録はありません")
      end

      it "shows link to timer" do
        get workout_log_date_path(date)
        expect(response.body).to include("タイマーを開始")
        expect(response.body).to include('href="/timer"')
      end
    end

    context "with invalid date" do
      it "redirects to index with error message" do
        get "/workout_logs/invalid-date"
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("Invalid date")
      end
    end

    context "without authentication" do
      before do
        delete logout_path
      end

      it "redirects to login page" do
        get workout_log_date_path(date)
        expect(response).to redirect_to(login_path)
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
