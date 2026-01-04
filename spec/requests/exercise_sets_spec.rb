require 'rails_helper'

RSpec.describe "ExerciseSets", type: :request do
  let(:user) { User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com') }
  let(:exercise_set) { user.exercise_sets.create!(name: "Morning Routine", rounds: 2) }

  before do
    sign_in(user)
  end

  describe "GET /exercise_sets" do
    it "returns http success" do
      get exercise_sets_path
      expect(response).to have_http_status(:success)
    end

    it "displays the presets list" do
      exercise_set
      get exercise_sets_path
      expect(response.body).to include("Morning Routine")
    end
  end

  describe "GET /exercise_sets/new" do
    it "returns http success" do
      get new_exercise_set_path
      expect(response).to have_http_status(:success)
    end

    it "displays the form" do
      get new_exercise_set_path
      expect(response.body).to include("New Preset")
    end
  end

  describe "POST /exercise_sets" do
    it "creates a new exercise set" do
      expect {
        post exercise_sets_path, params: {
          exercise_set: {
            name: "Evening Workout",
            rounds: 3,
            exercise_items_attributes: [
              { name: "Squats", exercise_seconds: 30, rest_seconds: 15, position: 0 }
            ]
          }
        }
      }.to change(ExerciseSet, :count).by(1)
    end

    it "redirects to index after creation" do
      post exercise_sets_path, params: {
        exercise_set: {
          name: "Evening Workout",
          rounds: 3,
          exercise_items_attributes: [
            { name: "Squats", exercise_seconds: 30, rest_seconds: 15, position: 0 }
          ]
        }
      }
      expect(response).to redirect_to(exercise_sets_path)
    end
  end

  describe "GET /exercise_sets/:id/edit" do
    it "returns http success" do
      get edit_exercise_set_path(exercise_set)
      expect(response).to have_http_status(:success)
    end

    it "displays the edit form" do
      get edit_exercise_set_path(exercise_set)
      expect(response.body).to include("Edit Preset")
      expect(response.body).to include("Morning Routine")
    end
  end

  describe "PATCH /exercise_sets/:id" do
    it "updates the exercise set" do
      patch exercise_set_path(exercise_set), params: {
        exercise_set: { name: "Updated Routine" }
      }
      expect(exercise_set.reload.name).to eq("Updated Routine")
    end

    it "redirects to index after update" do
      patch exercise_set_path(exercise_set), params: {
        exercise_set: { name: "Updated Routine" }
      }
      expect(response).to redirect_to(exercise_sets_path)
    end
  end

  describe "DELETE /exercise_sets/:id" do
    it "deletes the exercise set" do
      exercise_set
      expect {
        delete exercise_set_path(exercise_set)
      }.to change(ExerciseSet, :count).by(-1)
    end

    it "redirects to index after deletion" do
      delete exercise_set_path(exercise_set)
      expect(response).to redirect_to(exercise_sets_path)
    end
  end

  describe "without authentication" do
    before do
      delete logout_path
    end

    it "redirects to login page" do
      get exercise_sets_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe "POST /exercise_sets/:id/set_default" do
    it "sets the exercise set as default" do
      post set_default_exercise_set_path(exercise_set)
      expect(exercise_set.reload.default).to be true
    end

    it "redirects to index" do
      post set_default_exercise_set_path(exercise_set)
      expect(response).to redirect_to(exercise_sets_path)
    end

    it "clears other defaults" do
      other_set = user.exercise_sets.create!(name: "Other", rounds: 1, default: true)
      post set_default_exercise_set_path(exercise_set)
      expect(other_set.reload.default).to be false
      expect(exercise_set.reload.default).to be true
    end
  end

  describe "accessing other user's exercise sets" do
    let(:other_user) { User.create!(provider: 'google_oauth2', uid: '456', name: 'Other', email: 'other@example.com') }
    let(:other_set) { other_user.exercise_sets.create!(name: "Other's Set", rounds: 1) }

    it "returns not found for edit" do
      get edit_exercise_set_path(other_set)
      expect(response).to have_http_status(:not_found)
    end

    it "returns not found for update" do
      patch exercise_set_path(other_set), params: { exercise_set: { name: "Hacked" } }
      expect(response).to have_http_status(:not_found)
    end

    it "returns not found for delete" do
      delete exercise_set_path(other_set)
      expect(response).to have_http_status(:not_found)
    end

    it "returns not found for set_default" do
      post set_default_exercise_set_path(other_set)
      expect(response).to have_http_status(:not_found)
    end
  end
end
