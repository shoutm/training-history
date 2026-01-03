class WorkoutLogsController < ApplicationController
  def index
    @current_month = params[:month] ? Date.parse(params[:month]) : Date.current
    @workout_logs = WorkoutLog.in_month(@current_month).pluck(:date).to_set
    @prev_month = @current_month.prev_month
    @next_month = @current_month.next_month
  end

  def toggle
    date = Date.parse(params[:date])
    workout_log = WorkoutLog.find_by(date: date)

    if workout_log
      workout_log.destroy
    else
      WorkoutLog.create!(date: date)
    end

    redirect_to root_path(month: date.beginning_of_month.to_s)
  end
end
