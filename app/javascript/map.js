// ※ 現在は app/assets/javascripts/map.js を使用中（Sprockets対応）こちら未使用


// ✅ Turbo対応でマップを再初期化する
document.addEventListener("turbo:load", initMap);
document.addEventListener("turbo:render", initMap);

// ✅ Google Map初期化関数（1つだけ）
function initMap() {
  console.log("✅ Google Map initialized!");
  const mapDiv = document.getElementById("map");
  if (!mapDiv) {
    console.warn("⚠️ #map が見つかりません。ページを確認してください。");
    return;
  }

  // Google Map インスタンスをグローバル変数に保持
  window.map = new google.maps.Map(mapDiv, {
    center: { lat: 35.681236, lng: 139.767125 }, // 東京駅
    zoom: 10,
    mapId: "DEMO_MAP_ID",
  });
  console.log("🗺️ Map オブジェクト初期化完了");
}

// ✅ Turbo対応：現在地ボタンイベント
document.addEventListener("turbo:load", () => {
  console.log("⚡ turbo:load 発火");

  const currentLocationBtn = document.getElementById("current-location-btn");
  const resultsContainer = document.getElementById("results-container");
  const statusMessage = document.getElementById("search-status-message");

  if (!currentLocationBtn) {
    console.warn("⚠️ 現在地ボタンが見つかりません。");
    return;
  }

  // イベントが重複しないよう一旦リスナー削除
  currentLocationBtn.replaceWith(currentLocationBtn.cloneNode(true));
  const newBtn = document.getElementById("current-location-btn");

  newBtn.addEventListener("click", async () => {
    console.log("📍 ボタンがクリックされました！（Turbo対応）");

    if (!window.map) {
      console.warn("⚠️ map 未初期化 → initMap 呼び出し");
      initMap();
    }

    if (statusMessage) {
      statusMessage.textContent = "🔍 現在地から遊び場を検索中です…（数秒かかる場合があります）";
    }

    if (!navigator.geolocation) {
      alert("このブラウザでは位置情報が利用できません。");
      if (statusMessage) statusMessage.textContent = "";
      return;
    }

    const isLocal = window.location.hostname === "localhost";
    const options = {
      enableHighAccuracy: isLocal,
      timeout: isLocal ? 15000 : 20000,
      maximumAge: 0,
    };

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const { latitude: lat, longitude: lng } = position.coords;
        console.log("✅ 現在地取得:", lat, lng);

        const currentPosition = { lat, lng };
        window.map.setCenter(currentPosition);
        window.map.setZoom(15);

        // ✅ 青い現在地マーカー
        new google.maps.Marker({
          map: window.map,
          position: currentPosition,
          title: "あなたの現在地",
          icon: { url: "https://maps.google.com/mapfiles/ms/icons/blue-dot.png" },
        });

        // ✅ Rails API呼び出し（DBの遊び場データ取得）
        const url = `/playgrounds/nearby?lat=${lat}&lng=${lng}`;
        console.log("🌐 Fetching:", url);

        try {
          const res = await fetch(url, { headers: { "Accept": "application/json" } });

          console.log("📡 API status:", res.status);
          const data = await res.json();
          console.log("🎯 周辺データ取得:", data);

          if (statusMessage) {
            statusMessage.textContent = "✅ 検索が完了しました！";
            setTimeout(() => (statusMessage.textContent = ""), 3000);
          }

          // 既存マーカー削除
          if (window.playgroundMarkers) {
            window.playgroundMarkers.forEach((m) => m.setMap(null));
          }
          window.playgroundMarkers = [];

          if (Array.isArray(data) && data.length > 0) {
            const nearby = data
              .map((place) => {
                const d = getDistanceFromLatLng(lat, lng, place.lat, place.lng);
                return { ...place, distance: d };
              })
              .filter((p) => p.distance <= 1200)
              .sort((a, b) => a.distance - b.distance);

            renderResultsList(nearby);

            // ✅ 赤ピンマーカー追加
            nearby.forEach((place) => {
              const marker = new google.maps.Marker({
                map: window.map,
                position: { lat: place.lat, lng: place.lng },
                title: place.name,
                icon: { url: "https://maps.google.com/mapfiles/ms/icons/red-dot.png" },
              });

              const infoWindow = new google.maps.InfoWindow({
                content: `
                  <div style="max-width:230px">
                    <strong>${place.name}</strong><br>
                    ⭐ ${place.rating || "評価なし"}（${place.user_ratings_total || 0}件）<br>
                    <small>${place.address || "住所情報なし"}</small><br>
                    ${
                      place.photo_url
                        ? `<img src="${place.photo_url}" alt="${place.name}" class="w-full h-24 object-cover rounded mt-1">`
                        : ""
                    }
                    <a href="https://www.google.com/maps/place/?q=place_id:${place.place_id}" target="_blank"
                      class="text-blue-500 hover:underline text-sm">Googleマップで見る</a>
                  </div>
                `,
              });

              marker.addListener("click", () => infoWindow.open(window.map, marker));
              window.playgroundMarkers.push(marker);
            });
          } else {
            resultsContainer.innerHTML =
              `<p class="text-center text-gray-500 mt-4">🎈 近くに遊び場が見つかりませんでした。</p>`;
          }
        } catch (err) {
          console.error("❌ Fetchエラー:", err);
          alert("遊び場情報の取得に失敗しました。");
          if (statusMessage) statusMessage.textContent = "";
        }
      },
      (error) => {
        console.error("❌ 位置情報エラー:", error);

        const messages = {
          [error.PERMISSION_DENIED]: "❌ 位置情報の利用が拒否されました。設定をご確認ください。",
          [error.POSITION_UNAVAILABLE]: "⚠️ 位置情報を取得できません（通信またはGPSの問題）。",
          [error.TIMEOUT]: "⏱ 位置情報の取得がタイムアウトしました。",
          default: "❓ 不明なエラーが発生しました。",
        };

        alert(messages[error.code] || messages.default);
        if (statusMessage) statusMessage.textContent = "";
      },
      options
    );
  });
});

// ✅ 距離計算関数
function getDistanceFromLatLng(lat1, lng1, lat2, lng2) {
  const R = 6371e3;
  const φ1 = (lat1 * Math.PI) / 180;
  const φ2 = (lat2 * Math.PI) / 180;
  const Δφ = ((lat2 - lat1) * Math.PI) / 180;
  const Δλ = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(Δφ / 2) ** 2 +
    Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// ✅ 結果リスト描画関数
function renderResultsList(data) {
  const container = document.getElementById("results-container");
  if (!container) return;

  container.innerHTML = data
    .map(
      (p) => `
        <div class="bg-white rounded-lg shadow p-3 border border-gray-100 hover:shadow-md transition">
          <h3 class="font-bold text-gray-800">${p.name}</h3>
          <p class="text-sm text-gray-600 mb-1">${p.address || "住所情報なし"}</p>
          <p class="text-yellow-600 text-sm mb-1">⭐ ${p.rating || "評価なし"}</p>
          <p class="text-gray-500 text-xs mb-1">🚶 ${(p.distance / 1000).toFixed(2)} km</p>
          <a href="https://www.google.com/maps/place/?q=place_id:${p.place_id}"
             target="_blank" class="text-blue-500 hover:underline text-sm">Googleマップで見る</a>
        </div>`
    )
    .join("");
}

// ✅ Google Maps callback 用
window.initMap = initMap;
