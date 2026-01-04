class TimerController < ApplicationController
  def show
    @exercise_sets = current_user.exercise_sets.includes(:exercise_items)
    if params[:exercise_set_id]
      @exercise_set = current_user.exercise_sets.includes(:exercise_items).find_by(id: params[:exercise_set_id])
    end
  end
end
