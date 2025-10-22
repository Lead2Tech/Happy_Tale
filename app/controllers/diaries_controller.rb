class DiariesController < ApplicationController
  before_action :authenticate_user!  # ログイン必須にする

  def index
    @diaries = Diary.all
  end

  def show
    @diary = Diary.find(params[:id])
  end

  def new
    @diary = Diary.new
  end

  def create
    @diary = current_user.diaries.build(diary_params)
    if @diary.save
      redirect_to @diary, notice: "日記を投稿しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @diary = current_user.diaries.find(params[:id])
  end

  def update
    @diary = current_user.diaries.find(params[:id])
    if @diary.update(diary_params)
      redirect_to @diary, notice: "日記を更新しました！"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @diary = current_user.diaries.find(params[:id])
    @diary.destroy
    redirect_to diaries_path, notice: "日記を削除しました。"
  end

  private

  def diary_params
    params.require(:diary).permit(:title, :content, :visited_at, :playground_id)
  end
end
