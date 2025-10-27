// ✅ Google Map初期化関数
function initMap() {
  console.log("✅ Google Map initialized!");

  const mapDiv = document.getElementById("map");
  if (!mapDiv) return;

  // 🗺️ 地図の初期設定（東京駅付近）
  const map = new google.maps.Map(mapDiv, {
    center: { lat: 35.681236, lng: 139.767125 },
    zoom: 10,
    mapId: "DEMO_MAP_ID",
  });

  const currentLocationBtn = document.getElementById("current-location-btn");
  if (!currentLocationBtn) return;

  // 📍 現在地ボタンがクリックされたとき
  currentLocationBtn.addEventListener("click", async () => {
    console.log("📍 ボタンがクリックされました！");

    if (!navigator.geolocation) {
      alert("このブラウザでは位置情報が利用できません。");
      return;
    }

    // ⏳ タイムアウト設定付きで現在地取得
    const options = { enableHighAccuracy: true, timeout: 5000, maximumAge: 0 };

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const lat = position.coords.latitude;
        const lng = position.coords.longitude;
        console.log("✅ 現在地取得:", lat, lng);

        const currentPosition = { lat, lng };
        map.setCenter(currentPosition);
        map.setZoom(15);

        // ✅ 現在地マーカー（AdvancedMarkerElement使用）
        new google.maps.marker.AdvancedMarkerElement({
          map,
          position: currentPosition,
          title: "あなたの現在地",
        });

        // ✅ RailsのAPIにリクエスト
        const url = `/playgrounds/nearby?lat=${lat}&lng=${lng}`;
        console.log("🌐 Fetching:", url);

        try {
          const res = await fetch(url);
          console.log("📡 API status:", res.status);
          const data = await res.json();
          console.log("🎯 周辺の遊び場データ:", data);

          // 🔄 既存マーカー削除
          if (window.playgroundMarkers) {
            window.playgroundMarkers.forEach((m) => m.map = null);
          }
          window.playgroundMarkers = [];

          if (Array.isArray(data) && data.length > 0) {
            data.forEach((place) => {
              if (!place.geometry || !place.geometry.location) return;

              const position = {
                lat: place.geometry.location.lat,
                lng: place.geometry.location.lng,
              };

              // ✅ 遊び場マーカーをAdvancedMarkerElementで追加
              const marker = new google.maps.marker.AdvancedMarkerElement({
                map,
                position,
                title: place.name,
              });

              // 🏷️ 吹き出し情報
              const photoHtml = place.photo_url
                ? `<img src="${place.photo_url}" alt="${place.name}" class="w-full h-24 object-cover rounded mb-1">`
                : "";

              const ratingHtml = place.rating
                ? `⭐ ${place.rating}（${place.user_ratings_total || 0}件）`
                : "評価なし";

              const infoWindow = new google.maps.InfoWindow({
                content: `
                  <div style="max-width:230px">
                    ${photoHtml}
                    <strong>${place.name}</strong><br>
                    <small>${place.address || "住所情報なし"}</small><br>
                    <span>${ratingHtml}</span><br>
                    <a href="https://www.google.com/maps/place/?q=place_id:${place.place_id}"
                       target="_blank" class="text-blue-500 hover:underline">Googleマップで見る</a>
                  </div>
                `,
              });

              marker.addListener("click", () => {
                infoWindow.open(map, marker);
              });

              window.playgroundMarkers.push(marker);
            });
          } else {
            alert("近くに遊び場が見つかりませんでした。");
          }
        } catch (err) {
          console.error("❌ Fetchエラー:", err);
          alert("遊び場情報の取得に失敗しました。");
        }
      },
      (error) => {
        console.error("❌ 位置情報エラー:", error);
        switch (error.code) {
          case error.PERMISSION_DENIED:
            alert("位置情報の利用が拒否されました。");
            break;
          case error.POSITION_UNAVAILABLE:
            alert("位置情報を取得できませんでした（信号なし）。");
            break;
          case error.TIMEOUT:
            alert("位置情報の取得がタイムアウトしました。");
            break;
          default:
            alert("不明なエラーが発生しました。");
        }
      },
      options
    );
  });
}

// ✅ Turbo対応（Railsで必須）
document.addEventListener("turbo:load", () => {
  console.log("⚡ turbo:load 発火");
  if (typeof google !== "undefined") {
    initMap();
  } else {
    console.warn("⚠️ google undefined");
  }
});

// ✅ グローバルで呼び出せるように
window.initMap = initMap;
