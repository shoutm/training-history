class CreateNotificationSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.time :notify_at
      t.boolean :enabled, default: false, null: false

      t.timestamps
    end

    add_index :notification_settings, [ :user_id, :day_of_week ], unique: true
  end
end
