require "json"
require "open-uri"

class PlaygroundsController < ApplicationController
  def nearby
    lat = params[:lat]
    lng = params[:lng]
    return render json: { error: "位置情報がありません" }, status: 400 unless lat && lng

    keywords = [
      "子供 遊び場",
      "公園",
      "キッズパーク",
      "park",
      "playground",
      "indoor playground",
      "kids park",
      "zoo",
      "theme park",
      "amusement park"
    ]

    threads = []
    results = []

    keywords.each do |word|
      threads << Thread.new do
        query = URI.encode_www_form_component(word)
        url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{lat},#{lng}&radius=15000&keyword=#{query}&language=ja&key=#{ENV['GOOGLE_MAPS_API_KEY']}"
        begin
          response = URI.parse(url).open.read
          data = JSON.parse(response)
          puts "📡 [#{word}] #{data['results']&.length || 0}件ヒット"
          results.concat(data["results"]) if data["results"].present?
        rescue => e
          Rails.logger.error "❌ Google APIエラー（#{word}）: #{e.message}"
        end
      end
    end

    # 全スレッドが終わるのを待つ
    threads.each(&:join)

    unique_results = results.uniq { |r| r["place_id"] }

    render json: unique_results
  end
end
