class ExerciseSetsController < ApplicationController
  before_action :set_exercise_set, only: [ :edit, :update, :destroy, :set_default ]

  def index
    @exercise_sets = current_user.exercise_sets.includes(:exercise_items)
  end

  def new
    @exercise_set = current_user.exercise_sets.build(rounds: 1)
    @exercise_set.exercise_items.build(position: 0)
  end

  def create
    @exercise_set = current_user.exercise_sets.build(exercise_set_params)
    if @exercise_set.save
      redirect_to exercise_sets_path, notice: "プリセットを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @exercise_set.update(exercise_set_params)
      redirect_to exercise_sets_path, notice: "プリセットを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @exercise_set.destroy
    redirect_to exercise_sets_path, notice: "プリセットを削除しました"
  end

  def set_default
    @exercise_set.set_as_default!
    redirect_to exercise_sets_path, notice: "「#{@exercise_set.name}」をデフォルトに設定しました"
  end

  private

  def set_exercise_set
    @exercise_set = current_user.exercise_sets.find(params[:id])
  end

  def exercise_set_params
    params.require(:exercise_set).permit(
      :name, :rounds, :default,
      exercise_items_attributes: [ :id, :name, :exercise_seconds, :rest_seconds, :position, :_destroy ]
    )
  end
end
