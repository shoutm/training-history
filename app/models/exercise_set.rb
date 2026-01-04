class ExerciseSet < ApplicationRecord
  belongs_to :user
  has_many :exercise_items, -> { order(:position) }, dependent: :destroy

  validates :name, presence: true
  validates :rounds, presence: true, numericality: { greater_than: 0 }

  accepts_nested_attributes_for :exercise_items, allow_destroy: true, reject_if: :all_blank

  before_save :clear_other_defaults, if: :default?

  def self.default_set
    find_by(default: true)
  end

  def set_as_default!
    update!(default: true)
  end

  private

  def clear_other_defaults
    user.exercise_sets.where(default: true).where.not(id: id).update_all(default: false)
  end
end
