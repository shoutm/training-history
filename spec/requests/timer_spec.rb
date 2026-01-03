require 'rails_helper'

RSpec.describe "Timer", type: :request do
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
end
