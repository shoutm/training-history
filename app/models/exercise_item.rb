class ExerciseItem < ApplicationRecord
  belongs_to :exercise_set

  validates :name, presence: true
  validates :exercise_seconds, presence: true, numericality: { greater_than: 0 }
  validates :rest_seconds, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
