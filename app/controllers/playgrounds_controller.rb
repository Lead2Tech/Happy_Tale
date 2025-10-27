class PlaygroundsController < ApplicationController
  # ✅ 未ログインでも見れるページを指定
  before_action :authenticate_user!, except: [:index, :show, :search_mode]
  before_action :set_playground, only: [:show, :edit, :update, :destroy]

  require 'open-uri'
  require 'json'

  def index
    if params[:lat].present? && params[:lng].present?
      # 📍 現在地が送られてきた場合（Nearby Search）
      lat = params[:lat]
      lng = params[:lng]

      # 日本語を含むキーワードをURLエンコード
      keyword = URI.encode_www_form_component("公園 OR 遊び場 OR キッズパーク")

      url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{lat},#{lng}&radius=3000&keyword=#{keyword}&language=ja&key=#{ENV['GOOGLE_MAPS_API_KEY']}"
      response = URI.open(url).read
      data = JSON.parse(response)
      @playgrounds = data["results"].map do |place|
        OpenStruct.new(
          name: place["name"],
          address: place["vicinity"],
          rating: place["rating"],
          lat: place.dig("geometry", "location", "lat"),
          lng: place.dig("geometry", "location", "lng")
        )
      end

    elsif params[:q].present?
      # 🔍 通常のキーワード検索（DB検索）
      @playgrounds = Playground.where("name LIKE ?", "%#{params[:q]}%")
    else
      # 🗺 すべての遊び場を表示（DB内）
      @playgrounds = Playground.all
    end
  end

  def show
    if @playground.name.present?
      url = URI("https://places.googleapis.com/v1/places:searchText")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["Content-Type"] = "application/json"
      request["X-Goog-Api-Key"] = ENV["GOOGLE_MAPS_API_KEY"]
      request["X-Goog-FieldMask"] = "places.displayName,places.formattedAddress,places.rating,places.userRatingCount,places.photos"
      request.body = { textQuery: @playground.name }.to_json

      response = https.request(request)
      data = JSON.parse(response.body)

      puts "📡 Google API Response: #{data.inspect}"
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
