# app/controllers/playgrounds_controller.rb
require "json"
require "open-uri"

class PlaygroundsController < ApplicationController
  def nearby
    lat = params[:lat]
    lng = params[:lng]
    return render json: { error: "位置情報がありません" }, status: 400 unless lat && lng

    cache_key = "playgrounds_db_#{lat.to_f.round(2)}_#{lng.to_f.round(2)}"

    # ✅ まずキャッシュ確認
    if Rails.cache.exist?(cache_key)
      cached = Rails.cache.read(cache_key)
      puts "⚡️ キャッシュヒット！(#{cache_key})"
      return render json: cached
    end

    puts "🌍 検索開始 (キャッシュなし: #{cache_key})"

    # ✅ DB検索モード（範囲絞り込みで高速化）
    lat_f = lat.to_f
    lng_f = lng.to_f

    db_results = Playground
      .where(lat: (lat_f - 0.02)..(lat_f + 0.02)) # 約2km四方
      .where(lng: (lng_f - 0.02)..(lng_f + 0.02))
      .select do |p|
        haversine_distance(lat_f, lng_f, p.lat, p.lng) <= 2000 # 実際に2km以内だけ残す
      end

    if db_results.present?
      puts "📦 DBデータ取得: #{db_results.size}件"
      Rails.cache.write(cache_key, db_results, expires_in: 72.hours)
      return render json: db_results
    end

    # ✅ 本番モードではAPI呼び出ししない
    if ENV["PLAYGROUND_MODE"] == "db_only"
      puts "🚫 本番モードのためAPI呼び出しをスキップ"
      return render json: db_results
    end

    # ✅ 開発モードのみAPIを使用（DBデータがなかった場合）
    puts "🔍 Google API呼び出し開始"
    query = URI.encode_www_form_component("公園")
    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{lat},#{lng}&radius=2000&keyword=#{query}&language=ja&key=#{ENV['GOOGLE_MAPS_API_KEY']}"

    results = []

    begin
      data = JSON.parse(URI.open(url).read)
      data["results"].each do |r|
        results << {
          name: r["name"],
          address: r["vicinity"],
          rating: r["rating"],
          lat: r.dig("geometry", "location", "lat"),
          lng: r.dig("geometry", "location", "lng"),
          place_id: r["place_id"]
        }

        Playground.find_or_create_by(place_id: r["place_id"]) do |pg|
          pg.name = r["name"]
          pg.address = r["vicinity"]
          pg.rating = r["rating"]
          pg.lat = r.dig("geometry", "location", "lat")
          pg.lng = r.dig("geometry", "location", "lng")
        end
      end
    rescue => e
      Rails.logger.error "❌ Google APIエラー: #{e.message}"
    end

    Rails.cache.write(cache_key, results, expires_in: 72.hours)
    render json: results
  end

  private

  # ✅ 距離計算メソッド（メートル単位）
  def haversine_distance(lat1, lng1, lat2, lng2)
    r = 6371e3
    phi1 = lat1 * Math::PI / 180
    phi2 = lat2 * Math::PI / 180
    dphi = (lat2 - lat1) * Math::PI / 180
    dlambda = (lng2 - lng1) * Math::PI / 180

    a = Math.sin(dphi / 2)**2 + Math.cos(phi1) * Math.cos(phi2) * Math.sin(dlambda / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    r * c
  end
end
