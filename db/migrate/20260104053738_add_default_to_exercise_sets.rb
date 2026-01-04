class AddDefaultToExerciseSets < ActiveRecord::Migration[8.1]
  def change
    add_column :exercise_sets, :default, :boolean, default: false, null: false
  end
end
