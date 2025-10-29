require "json"
require "open-uri"

class PlaygroundsController < ApplicationController
  def nearby
    start_time = Time.current
    puts "🚀 [Start] playgrounds#nearby"

    lat = params[:lat]
    lng = params[:lng]
    return render json: { error: "位置情報がありません" }, status: 400 unless lat && lng

    cache_key = "playgrounds_db_#{lat.to_f.round(2)}_#{lng.to_f.round(2)}"

    # ✅ キャッシュ確認
    if Rails.cache.exist?(cache_key)
      cached = Rails.cache.read(cache_key)
      puts "⚡️ キャッシュヒット！（#{cache_key}）"
      puts "⏱ 全体処理時間: #{(Time.current - start_time).round(2)}秒"
      return render json: cached
    end

    puts "🌍 キャッシュなし → DB検索開始"

    lat_f = lat.to_f
    lng_f = lng.to_f

    # ✅ DB検索時間計測
    db_start = Time.current
    db_results = Playground
      .where.not(lat: nil, lng: nil)
      .where(lat: (lat_f - 0.02)..(lat_f + 0.02))
      .where(lng: (lng_f - 0.02)..(lng_f + 0.02))
      .select do |p|
        haversine_distance(lat_f, lng_f, p.lat, p.lng) <= 2000
      end
    db_end = Time.current
    puts "📦 DB検索時間: #{(db_end - db_start).round(2)}秒 / 結果: #{db_results.size}件"

    # ✅ DBデータがある場合 → JSONで返す
    if db_results.present?
      json_results = db_results.map do |p|
        {
          id: p.id,
          name: p.name,
          address: p.address,
          rating: p.rating,
          lat: p.lat,
          lng: p.lng,
          place_id: p.place_id,
          photo_url: p.respond_to?(:photo_url) ? p.photo_url : nil,
          user_ratings_total: p.respond_to?(:user_ratings_total) ? p.user_ratings_total : nil
        }
      end

      Rails.cache.write(cache_key, json_results, expires_in: 72.hours)
      puts "✅ DB結果をキャッシュ保存しました（#{cache_key}）"
      puts "⏱ 全体処理時間: #{(Time.current - start_time).round(2)}秒"
      return render json: json_results
    end

    # ✅ 本番モードではAPI呼び出ししない
    if ENV["PLAYGROUND_MODE"] == "db_only"
      puts "🚫 本番モード：Google API呼び出しをスキップ"
      puts "⏱ 全体処理時間: #{(Time.current - start_time).round(2)}秒"
      return render json: []
    end

    # ✅ API呼び出し時間計測
    puts "🔍 Google API呼び出し開始"
    api_start = Time.current
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
    api_end = Time.current
    puts "🌐 Google API呼び出し時間: #{(api_end - api_start).round(2)}秒 / 結果: #{results.size}件"

    Rails.cache.write(cache_key, results, expires_in: 72.hours)
    total_time = (Time.current - start_time).round(2)
    puts "✅ [Done] 全体処理時間: #{total_time}秒"

    render json: results
  end

  private

  # ✅ 距離計算（メートル）
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
