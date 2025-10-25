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

  def show
  require 'net/http'
  require 'json'

  if @playground.name.present?
    url = URI("https://places.googleapis.com/v1/places:searchText")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["X-Goog-Api-Key"] = ENV["GOOGLE_MAPS_API_KEY"]
    request["X-Goog-FieldMask"] = "places.displayName,places.formattedAddress,places.rating,places.userRatingCount,places.photos"  # ←これ重要！
    request.body = { textQuery: @playground.name }.to_json

    response = https.request(request)
    data = JSON.parse(response.body)

    puts "📡 Google API Response: #{data.inspect}" # ←ログ確認用（ターミナルで見える）
    @place = data["places"]&.first
  end
end


  def new
    @playground = Playground.new
  end

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
