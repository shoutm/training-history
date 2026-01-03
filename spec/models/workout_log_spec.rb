require 'rails_helper'

RSpec.describe WorkoutLog, type: :model do
  describe 'validations' do
    it 'is valid with a date' do
      workout_log = WorkoutLog.new(date: Date.current)
      expect(workout_log).to be_valid
    end

    it 'is invalid without a date' do
      workout_log = WorkoutLog.new(date: nil)
      expect(workout_log).not_to be_valid
      expect(workout_log.errors[:date]).to include("can't be blank")
    end

    it 'is invalid with a duplicate date' do
      WorkoutLog.create!(date: Date.current)
      workout_log = WorkoutLog.new(date: Date.current)
      expect(workout_log).not_to be_valid
      expect(workout_log.errors[:date]).to include("has already been taken")
    end
  end

  describe 'default values' do
    it 'sets completed to true by default' do
      workout_log = WorkoutLog.create!(date: Date.current)
      expect(workout_log.completed).to be true
    end
  end

  describe '.in_month' do
    let!(:jan_log1) { WorkoutLog.create!(date: Date.new(2026, 1, 5)) }
    let!(:jan_log2) { WorkoutLog.create!(date: Date.new(2026, 1, 15)) }
    let!(:feb_log) { WorkoutLog.create!(date: Date.new(2026, 2, 10)) }

    it 'returns logs within the specified month' do
      result = WorkoutLog.in_month(Date.new(2026, 1, 1))
      expect(result).to include(jan_log1, jan_log2)
      expect(result).not_to include(feb_log)
    end

    it 'returns empty when no logs in the month' do
      result = WorkoutLog.in_month(Date.new(2026, 3, 1))
      expect(result).to be_empty
    end
  end

  describe '.completed' do
    let!(:completed_log) { WorkoutLog.create!(date: Date.new(2026, 1, 1), completed: true) }
    let!(:incomplete_log) { WorkoutLog.create!(date: Date.new(2026, 1, 2), completed: false) }

    it 'returns only completed logs' do
      result = WorkoutLog.completed
      expect(result).to include(completed_log)
      expect(result).not_to include(incomplete_log)
    end
  end
end
