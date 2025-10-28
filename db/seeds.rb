file = Rails.root.join("db/seeds/playgrounds_tokyo.json")
if File.exist?(file)
  puts "🌍 Seeding playgrounds from JSON..."
  data = JSON.parse(File.read(file))
  data.each do |r|
    Playground.find_or_create_by(place_id: r["place_id"]) do |pg|
      pg.name = r["name"]
      pg.address = r["address"]
      pg.rating = r["rating"]
      pg.lat = r["lat"]
      pg.lng = r["lng"]
      pg.user_id = User.find_by(email: "system@example.com")&.id
    end
  end
  puts "✅ Playground seeding complete!"
end
