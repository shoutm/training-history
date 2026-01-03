class AddUserToWorkoutLogs < ActiveRecord::Migration[8.1]
  def change
    # Remove existing data (development only)
    WorkoutLog.delete_all

    # Remove old unique index on date
    remove_index :workout_logs, :date

    # Add user reference
    add_reference :workout_logs, :user, null: false, foreign_key: true

    # Add composite unique index on user_id and date
    add_index :workout_logs, [ :user_id, :date ], unique: true
  end
end
