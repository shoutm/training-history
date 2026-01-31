class WorkoutLog < ApplicationRecord
  belongs_to :user
  belongs_to :exercise_set, optional: true

  validates :date, presence: true
  validates :exercise_set_id, uniqueness: { scope: [ :user_id, :date ], allow_nil: true }

  scope :in_month, ->(date) {
    where(date: date.beginning_of_month..date.end_of_month)
  }

  scope :completed, -> { where(completed: true) }
  scope :with_exercise_set, -> { where.not(exercise_set_id: nil) }
end
