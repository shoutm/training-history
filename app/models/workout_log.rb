class WorkoutLog < ApplicationRecord
  belongs_to :user

  validates :date, presence: true, uniqueness: { scope: :user_id }

  scope :in_month, ->(date) {
    where(date: date.beginning_of_month..date.end_of_month)
  }

  scope :completed, -> { where(completed: true) }
end
