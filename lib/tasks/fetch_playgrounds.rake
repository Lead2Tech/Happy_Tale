# lib/tasks/fetch_playgrounds.rake
namespace :playgrounds do
  desc "Fetch and store playgrounds for Tokyo 23 wards"
  task fetch_tokyo: :environment do
    require "open-uri"
    require "json"

    # ✅ Systemユーザー作成（nicknameを追加）
    system_user = User.find_or_create_by(email: "system@example.com") do |u|
      u.name = "System"
      u.nickname = "SystemBot"  # ← これを追加！
      u.password = SecureRandom.hex(10)
      u.password_confirmation = u.password if u.respond_to?(:password_confirmation)
    end

    if system_user.persisted?
      puts "👤 SystemユーザーID: #{system_user.id}"
    else
      puts "⚠️ Systemユーザーの作成に失敗しました: #{system_user.errors.full_messages.join(', ')}"
      abort("❌ Systemユーザーが作成できないため処理を中断します")
    end

    wards = [
      "千代田区", "中央区", "港区", "新宿区", "文京区", "台東区",
      "墨田区", "江東区", "品川区", "目黒区", "大田区", "世田谷区",
      "渋谷区", "中野区", "杉並区", "豊島区", "北区", "荒川区",
      "板橋区", "練馬区", "足立区", "葛飾区", "江戸川区"
    ]

    api_key = ENV["GOOGLE_MAPS_API_KEY"]

    wards.each do |ward|
      query = URI.encode_www_form_component("#{ward} 公園")
      url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{query}&language=ja&key=#{api_key}"

      puts "🌍 #{ward} の公園を取得中..."
      begin
        data = JSON.parse(URI.open(url).read)

        data["results"].each do |r|
          Playground.find_or_initialize_by(place_id: r["place_id"]).tap do |pg|
            pg.name = r["name"]
            pg.address = r["formatted_address"]
            pg.rating = r["rating"]
            pg.lat = r.dig("geometry", "location", "lat")
            pg.lng = r.dig("geometry", "location", "lng")
            pg.user_id = system_user.id

            if pg.save
              puts "💾 保存成功：#{pg.name}"
            else
              puts "❌ 保存失敗：#{pg.name || '不明'} | エラー内容：#{pg.errors.full_messages.join(', ')}"
            end
          end
        end

        puts "✅ #{ward} の登録完了（#{data['results'].count}件）"
      rescue => e
        puts "❌ #{ward} 取得エラー: #{e.message}"
      end

      sleep 2 # Google API呼び出し制限対策
    end

    puts "🎉 全区の公園データ登録完了！"
  end
end
