class DiariesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_diary, only: [:show, :edit, :update, :destroy]

  def index
    @diaries = current_user.diaries.order(created_at: :desc)
  end

  def show; end
  def new; @diary = Diary.new; end

  def create
    @diary = current_user.diaries.build(diary_params)
    if @diary.save
      redirect_to diaries_path, notice: "🌱 日記を投稿しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @diary.update(diary_params)
      redirect_to diaries_path, notice: "🪴 日記を更新しました！"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @diary.destroy
    redirect_to diaries_path, notice: "🗑️ 日記を削除しました。"
  end

  private

  def set_diary
    @diary = current_user.diaries.find(params[:id])
  end

  def diary_params
    params.require(:diary).permit(:title, :content, :visited_at, :playground_id)
  end
end
