require 'rails_helper'

RSpec.describe ExerciseSet, type: :model do
  let(:user) { User.create!(provider: 'google_oauth2', uid: '123', name: 'Test', email: 'test@example.com') }

  describe "validations" do
    it "is valid with a user, name, and rounds" do
      exercise_set = ExerciseSet.new(user: user, name: "Morning Routine", rounds: 2)
      expect(exercise_set).to be_valid
    end

    it "is invalid without a name" do
      exercise_set = ExerciseSet.new(user: user, rounds: 2)
      expect(exercise_set).not_to be_valid
      expect(exercise_set.errors[:name]).to include("can't be blank")
    end

    it "is invalid without rounds" do
      exercise_set = ExerciseSet.new(user: user, name: "Test", rounds: nil)
      expect(exercise_set).not_to be_valid
    end

    it "is invalid with rounds less than 1" do
      exercise_set = ExerciseSet.new(user: user, name: "Test", rounds: 0)
      expect(exercise_set).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to user" do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    it "has many exercise_items" do
      association = described_class.reflect_on_association(:exercise_items)
      expect(association.macro).to eq :has_many
    end

    it "destroys exercise_items when destroyed" do
      exercise_set = ExerciseSet.create!(user: user, name: "Test", rounds: 1)
      exercise_set.exercise_items.create!(name: "Push-ups", exercise_seconds: 30, rest_seconds: 15, position: 0)

      expect { exercise_set.destroy }.to change(ExerciseItem, :count).by(-1)
    end
  end

  describe "nested attributes" do
    it "accepts nested attributes for exercise_items" do
      exercise_set = ExerciseSet.create!(
        user: user,
        name: "Test Set",
        rounds: 2,
        exercise_items_attributes: [
          { name: "Push-ups", exercise_seconds: 30, rest_seconds: 15, position: 0 },
          { name: "Plank", exercise_seconds: 45, rest_seconds: 10, position: 1 }
        ]
      )

      expect(exercise_set.exercise_items.count).to eq 2
    end
  end
end
