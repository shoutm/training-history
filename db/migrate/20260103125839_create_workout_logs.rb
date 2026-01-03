class CreateWorkoutLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :workout_logs do |t|
      t.date :date, null: false
      t.boolean :completed, default: true, null: false

      t.timestamps
    end
    add_index :workout_logs, :date, unique: true
  end
end
