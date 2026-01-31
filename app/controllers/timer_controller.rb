class TimerController < ApplicationController
  def show
    @exercise_sets = current_user.exercise_sets.includes(:exercise_items)
    @exercise_set = if params[:exercise_set_id]
      current_user.exercise_sets.includes(:exercise_items).find_by(id: params[:exercise_set_id])
    elsif @exercise_sets.size == 1
      @exercise_sets.first
    else
      nil
    end
  end
end
