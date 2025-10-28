require "json"
require "open-uri"

class PlaygroundsController < ApplicationController
  def nearby
    lat = params[:lat]
    lng = params[:lng]
    return render json: { error: "位置情報がありません" }, status: 400 unless lat && lng

    # 🗝 キャッシュキー（緯度経度を小数第2位まで丸めてキャッシュ）
    cache_key = "playgrounds_#{lat.to_f.round(2)}_#{lng.to_f.round(2)}"

    # ✅ キャッシュがあれば即返す（超高速）
    if Rails.cache.exist?(cache_key)
      cached = Rails.cache.read(cache_key)
      puts "⚡️ キャッシュヒット！(#{cache_key})"
      return render json: cached
    end

    puts "🌍 APIリクエスト開始 (キャッシュなし: #{cache_key})"

    keywords = [
      "子供 遊び場",
      "公園",
      "水族館",
      "動物園",
      "遊園地",
      "玩具屋さん",
      "park",
      "zoo",
      "playground",
      "theme park"
    ]

    results = []

    keywords.each do |word|
      query = URI.encode_www_form_component(word)
      url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{lat},#{lng}&radius=1000&keyword=#{query}&language=ja&key=#{ENV['GOOGLE_MAPS_API_KEY']}"

      begin
        response = URI.parse(url).open.read
        data = JSON.parse(response)
        puts "📡 [#{word}] status=#{data['status']} | #{data['results']&.length || 0}件"

        next unless data["results"].present?

        # ✅ 詳細API呼び出しを削除（メモリ負荷軽減）
        data["results"].each do |r|
          photo_ref = r.dig("photos", 0, "photo_reference")
          photo_url = if photo_ref
            "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=#{photo_ref}&key=#{ENV['GOOGLE_MAPS_API_KEY']}"
          end

          results << {
            name: r["name"],
            address: r["vicinity"],
            rating: r["rating"],
            user_ratings_total: r["user_ratings_total"],
            photo_url: photo_url,
            geometry: r["geometry"],
            place_id: r["place_id"]
          }
        end

      rescue => e
        Rails.logger.error "❌ Google APIエラー（#{word}）: #{e.message}"
      end
    end

    unique_results = results.uniq { |r| r[:place_id] }

    # ✅ キャッシュに保存（24時間有効）
    Rails.cache.write(cache_key, unique_results, expires_in: 24.hours)
    puts "💾 キャッシュ保存完了 (#{cache_key})"

    render json: unique_results
  end
end
