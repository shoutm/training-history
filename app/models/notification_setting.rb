class NotificationSetting < ApplicationRecord
  belongs_to :user

  validates :day_of_week, presence: true,
            inclusion: { in: 0..6 },
            uniqueness: { scope: :user_id }
  validates :notify_at_utc, presence: true, if: :enabled?

  scope :enabled, -> { where(enabled: true) }
  scope :for_day, ->(day) { where(day_of_week: day) }

  DAY_NAMES = %w[日 月 火 水 木 金 土].freeze

  def day_name
    DAY_NAMES[day_of_week]
  end
end
