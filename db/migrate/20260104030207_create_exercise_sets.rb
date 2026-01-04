class CreateExerciseSets < ActiveRecord::Migration[8.1]
  def change
    create_table :exercise_sets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.integer :rounds, default: 1

      t.timestamps
    end
  end
end
