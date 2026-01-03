class User < ApplicationRecord
  has_many :workout_logs, dependent: :destroy

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :name, presence: true
  validates :email, presence: true

  def self.find_or_create_from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.name = auth.info.name
      user.email = auth.info.email
      user.avatar_url = auth.info.image
    end
  end
end
