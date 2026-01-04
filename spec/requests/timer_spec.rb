require 'rails_helper'

RSpec.describe "Timer", type: :request do
  let(:user) { User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com') }

  before do
    sign_in(user)
  end

  describe "GET /timer" do
    context "without any presets" do
      it "returns http success" do
        get timer_path
        expect(response).to have_http_status(:success)
      end

      it "displays the empty state" do
        get timer_path
        expect(response.body).to include("No exercise presets yet")
        expect(response.body).to include("Create Preset")
      end

      it "has a link back to the calendar" do
        get timer_path
        expect(response.body).to include('href="/"')
      end
    end

    context "with presets available but no default" do
      let!(:exercise_set) do
        set = user.exercise_sets.create!(name: "Morning Routine", rounds: 2)
        set.exercise_items.create!(name: "Push-ups", exercise_seconds: 30, rest_seconds: 15, position: 0)
        set
      end

      it "displays the preset selection page" do
        get timer_path
        expect(response.body).to include("Select Preset")
        expect(response.body).to include("Morning Routine")
      end

      it "shows preset details" do
        get timer_path
        expect(response.body).to include("2 rounds")
        expect(response.body).to include("1 exercise")
      end
    end

    context "with a default preset" do
      let!(:exercise_set) do
        set = user.exercise_sets.create!(name: "Default Routine", rounds: 3, default: true)
        set.exercise_items.create!(name: "Squats", exercise_seconds: 40, rest_seconds: 20, position: 0)
        set
      end

      it "loads the default preset automatically" do
        get timer_path
        expect(response.body).to include("Default Routine")
        expect(response.body).to include("Squats")
      end

      it "shows the timer interface" do
        get timer_path
        expect(response.body).to include('data-controller="timer"')
        expect(response.body).to include("Start")
      end
    end

    context "with a preset selected" do
      let!(:exercise_set) do
        set = user.exercise_sets.create!(name: "Morning Routine", rounds: 2)
        set.exercise_items.create!(name: "Push-ups", exercise_seconds: 30, rest_seconds: 15, position: 0)
        set.exercise_items.create!(name: "Plank", exercise_seconds: 45, rest_seconds: 10, position: 1)
        set
      end

      it "returns http success" do
        get timer_with_set_path(exercise_set)
        expect(response).to have_http_status(:success)
      end

      it "displays the preset name" do
        get timer_with_set_path(exercise_set)
        expect(response.body).to include("Morning Routine")
      end

      it "includes the Stimulus controller with exercises data" do
        get timer_with_set_path(exercise_set)
        expect(response.body).to include('data-controller="timer"')
        expect(response.body).to include('data-timer-exercises-value')
        expect(response.body).to include('data-timer-rounds-value="2"')
      end

      it "has control buttons" do
        get timer_with_set_path(exercise_set)
        expect(response.body).to include("Start")
        expect(response.body).to include("Pause")
        expect(response.body).to include("Reset")
      end

      it "displays the exercise list" do
        get timer_with_set_path(exercise_set)
        expect(response.body).to include("Push-ups")
        expect(response.body).to include("Plank")
      end
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
