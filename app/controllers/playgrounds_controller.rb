class PlaygroundsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_playground, only: [:show, :edit, :update, :destroy]

  def index
    if params[:q].present?
      @playgrounds = Playground.where("name LIKE ?", "%#{params[:q]}%")
    else
      @playgrounds = Playground.all
    end
  end

  def show; end
  def new; @playground = Playground.new; end

  def create
    @playground = Playground.new(playground_params)
    if @playground.save
      redirect_to playgrounds_path, notice: "🎉 遊び場を登録しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @playground.update(playground_params)
      redirect_to playgrounds_path, notice: "✅ 遊び場情報を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @playground.destroy
    redirect_to playgrounds_path, notice: "🗑️ 遊び場を削除しました。"
  end

  private

  def set_playground
    @playground = Playground.find(params[:id])
  end

  def playground_params
    params.require(:playground).permit(:name, :address, :description)
  end
end
