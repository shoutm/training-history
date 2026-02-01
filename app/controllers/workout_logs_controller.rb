class WorkoutLogsController < ApplicationController
  def index
    @current_month = params[:month] ? Date.parse(params[:month]) : Date.current
    @workout_logs_by_date = current_user.workout_logs
      .in_month(@current_month)
      .group_by(&:date)
    @prev_month = @current_month.prev_month
    @next_month = @current_month.next_month
  end

  def show
    @date = Date.parse(params[:date])
    @workout_logs = current_user.workout_logs
      .where(date: @date)
      .includes(exercise_set: :exercise_items)
      .order(:created_at)
  rescue ArgumentError
    redirect_to root_path, alert: "Invalid date"
  end

  def record
    date = Date.parse(params[:date])
    exercise_set_id = params[:exercise_set_id]

    current_user.workout_logs.create!(
      date: date,
      exercise_set_id: exercise_set_id,
      completed: true
    )

    redirect_to root_path(month: date.beginning_of_month.to_s, highlight: date.to_s)
  end
end
