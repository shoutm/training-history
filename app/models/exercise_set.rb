class ExerciseSet < ApplicationRecord
  belongs_to :user
  has_many :exercise_items, -> { order(:position) }, dependent: :destroy

  validates :name, presence: true
  validates :rounds, presence: true, numericality: { greater_than: 0 }

  accepts_nested_attributes_for :exercise_items, allow_destroy: true, reject_if: :all_blank
end
