class WorkoutLog < ApplicationRecord
  validates :date, presence: true, uniqueness: true

  scope :in_month, ->(date) {
    where(date: date.beginning_of_month..date.end_of_month)
  }

  scope :completed, -> { where(completed: true) }
end
