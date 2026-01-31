class AddExerciseSetToWorkoutLogs < ActiveRecord::Migration[8.1]
  def change
    # Add exercise_set_id (nullable for existing records)
    add_reference :workout_logs, :exercise_set, foreign_key: true

    # Remove old unique constraint on [user_id, date]
    remove_index :workout_logs, [:user_id, :date], if_exists: true

    # Add new unique constraint on [user_id, date, exercise_set_id]
    add_index :workout_logs, [:user_id, :date, :exercise_set_id], unique: true
  end
end
