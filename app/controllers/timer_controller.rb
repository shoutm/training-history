class TimerController < ApplicationController
  def show
    @exercise_sets = current_user.exercise_sets.includes(:exercise_items)
    @exercise_set = if params[:exercise_set_id]
      current_user.exercise_sets.includes(:exercise_items).find_by(id: params[:exercise_set_id])
    else
      @exercise_sets.default_set
    end

    @today_completed = current_user.workout_logs.exists?(date: Date.current)
  end
end
