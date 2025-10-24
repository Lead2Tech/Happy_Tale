class DiariesController < ApplicationController
  before_action :authenticate_user!  # ログイン必須にする

  def index
    # ✅ 自分の投稿だけを一覧表示（他人の投稿は見えない）
    @diaries = current_user.diaries.order(created_at: :desc)
  end

  def show
    # ✅ 他人の日記を直接URLで見れないようにする
    @diary = current_user.diaries.find(params[:id])
  end

  def new
    @diary = Diary.new
  end

  def create
    @diary = current_user.diaries.build(diary_params)
    if @diary.save
      # ✅ 投稿完了後は一覧ページに戻る
      redirect_to diaries_path, notice: "日記を投稿しました！"
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
      redirect_to diaries_path, notice: "日記を更新しました！"
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
