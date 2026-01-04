class CreateExerciseItems < ActiveRecord::Migration[8.1]
  def change
    create_table :exercise_items do |t|
      t.references :exercise_set, null: false, foreign_key: true
      t.string :name
      t.integer :exercise_seconds, default: 30
      t.integer :rest_seconds, default: 15
      t.integer :position

      t.timestamps
    end
  end
end
