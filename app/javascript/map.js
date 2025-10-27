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

  // 📍 現在地ボタンを押したとき
  currentLocationBtn.addEventListener("click", async () => {
    console.log("📍 ボタンがクリックされました！");

    if (!navigator.geolocation) {
      alert("このブラウザでは位置情報が利用できません。");
      return;
    }

    // 📡 現在地取得
    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const lat = position.coords.latitude;
        const lng = position.coords.longitude;
        console.log("✅ 現在地取得:", lat, lng);

        const currentPosition = { lat, lng };

        // ✅ 地図の中心とズームを移動
        map.setCenter(currentPosition);
        map.setZoom(14);

        // ✅ 現在地マーカー（青丸）
        new google.maps.marker.AdvancedMarkerElement({
          map,
          position: currentPosition,
          title: "あなたの現在地",
        });

        // ✅ Rails APIへアクセス
        const url = `/playgrounds/nearby?lat=${lat}&lng=${lng}`;
        console.log("🌐 Fetching:", url);

        try {
          const res = await fetch(url);
          console.log("📡 API status:", res.status);
          const data = await res.json();
          console.log("🎯 周辺の遊び場データ:", data);

          // ✅ 既存マーカー削除
          if (window.playgroundMarkers) {
            window.playgroundMarkers.forEach(m => m.map = null);
          }
          window.playgroundMarkers = [];

          if (Array.isArray(data) && data.length > 0) {
            data.forEach((place) => {
              if (!place.geometry || !place.geometry.location) return;

              const position = {
                lat: place.geometry.location.lat,
                lng: place.geometry.location.lng
              };

              // 📍 通常マーカー
              const marker = new google.maps.marker.AdvancedMarkerElement({
                map,
                position,
                title: place.name,
              });

              // 🏷️ 吹き出し内容
              const infoWindow = new google.maps.InfoWindow({
                content: `
                  <div style="max-width:230px">
                    <strong style="font-size:14px;">${place.name || "施設名不明"}</strong><br>
                    ${
                      place.photo_url
                        ? `<img src="${place.photo_url}" width="220" style="margin-top:5px;border-radius:8px;">`
                        : `<div style="background:#eee;height:120px;width:220px;display:flex;align-items:center;justify-content:center;border-radius:8px;">📷 No Image</div>`
                    }
                    <div style="margin-top:6px;font-size:13px;">
                      ⭐️ ${place.rating || "N/A"}（${place.user_ratings_total || 0}件）<br>
                      📍 ${place.address || "住所情報なし"}<br>
                      <a href="https://www.google.com/maps/place/?q=place_id:${place.place_id}" 
                         target="_blank"
                         style="color:#1a73e8;text-decoration:underline;display:inline-block;margin-top:4px;">
                         Googleマップで見る
                      </a>
                    </div>
                  </div>
                `,
              });

              // 📌 クリックでInfoWindowを開く
              marker.addListener("click", () => {
                infoWindow.open({ map, anchor: marker });
              });

              // 🧩 グローバル配列に追加
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
        alert("位置情報を取得できませんでした。");
      }
    );
  });
}

// ✅ Turbo対応（Railsで必須）
document.addEventListener("turbo:load", () => {
  if (typeof google !== "undefined") {
    initMap();
  }
});

// ✅ グローバルで呼び出せるように
window.initMap = initMap;
