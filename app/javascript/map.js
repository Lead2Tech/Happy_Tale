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
        new google.maps.Marker({
          map,
          position: currentPosition,
          title: "あなたの現在地",
          icon: {
            path: google.maps.SymbolPath.CIRCLE,
            scale: 8,
            fillColor: "#4285F4",
            fillOpacity: 1,
            strokeColor: "white",
            strokeWeight: 2,
          },
        });

        // ✅ Rails APIへアクセス
        const url = `/playgrounds/nearby?lat=${lat}&lng=${lng}`;
        console.log("🌐 Fetching:", url);

        try {
          const res = await fetch(url);
          console.log("📡 API status:", res.status);
          const data = await res.json();
          console.log("🎯 周辺の遊び場データ:", data);

          // ✅ 既存マーカー削除対策（新しい検索時）
          if (window.playgroundMarkers) {
            window.playgroundMarkers.forEach(m => m.setMap(null));
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
              const marker = new google.maps.Marker({
                map,
                position,
                title: place.name,
              });

              // 🏷️ 吹き出し（施設名＋住所）
              const infoWindow = new google.maps.InfoWindow({
                content: `
                  <div style="max-width:200px">
                    <strong>${place.name}</strong><br>
                    ${place.vicinity || place.formatted_address || "住所情報なし"}
                  </div>
                `,
              });

              marker.addListener("click", () => {
                infoWindow.open(map, marker);
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
