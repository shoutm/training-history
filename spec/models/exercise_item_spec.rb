require 'rails_helper'

RSpec.describe ExerciseItem, type: :model do
  let(:user) { User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com') }
  let(:exercise_set) { ExerciseSet.create!(user: user, name: "Test Set", rounds: 1) }

  describe "validations" do
    it "is valid with all required attributes" do
      item = ExerciseItem.new(
        exercise_set: exercise_set,
        name: "Push-ups",
        exercise_seconds: 30,
        rest_seconds: 15,
        position: 0
      )
      expect(item).to be_valid
    end

    it "is invalid without a name" do
      item = ExerciseItem.new(exercise_set: exercise_set, exercise_seconds: 30, rest_seconds: 15, position: 0)
      expect(item).not_to be_valid
      expect(item.errors[:name]).to include("can't be blank")
    end

    it "is invalid without exercise_seconds" do
      item = ExerciseItem.new(exercise_set: exercise_set, name: "Test", exercise_seconds: nil, rest_seconds: 15, position: 0)
      expect(item).not_to be_valid
    end

    it "is invalid with exercise_seconds less than 1" do
      item = ExerciseItem.new(exercise_set: exercise_set, name: "Test", exercise_seconds: 0, rest_seconds: 15, position: 0)
      expect(item).not_to be_valid
    end

    it "is invalid without rest_seconds" do
      item = ExerciseItem.new(exercise_set: exercise_set, name: "Test", exercise_seconds: 30, rest_seconds: nil, position: 0)
      expect(item).not_to be_valid
    end

    it "allows rest_seconds to be 0" do
      item = ExerciseItem.new(exercise_set: exercise_set, name: "Test", exercise_seconds: 30, rest_seconds: 0, position: 0)
      expect(item).to be_valid
    end

    it "is invalid without position" do
      item = ExerciseItem.new(exercise_set: exercise_set, name: "Test", exercise_seconds: 30, rest_seconds: 15, position: nil)
      expect(item).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to exercise_set" do
      association = described_class.reflect_on_association(:exercise_set)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe "default values" do
    it "has default exercise_seconds of 30" do
      item = ExerciseItem.new
      expect(item.exercise_seconds).to eq 30
    end

    it "has default rest_seconds of 15" do
      item = ExerciseItem.new
      expect(item.rest_seconds).to eq 15
    end
  end
end
