class WorkoutLogsController < ApplicationController
  def index
    @current_month = params[:month] ? Date.parse(params[:month]) : Date.current
    @workout_logs = current_user.workout_logs.in_month(@current_month).pluck(:date).to_set
    @prev_month = @current_month.prev_month
    @next_month = @current_month.next_month
  end

  def toggle
    date = Date.parse(params[:date])
    workout_log = current_user.workout_logs.find_by(date: date)

    if workout_log
      workout_log.destroy
      redirect_to root_path(month: date.beginning_of_month.to_s)
    else
      current_user.workout_logs.create!(date: date)
      redirect_to root_path(month: date.beginning_of_month.to_s, highlight: date.to_s)
    end
  end
end
