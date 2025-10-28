// ✅ Google Map初期化関数
function initMap() {
  console.log("✅ Google Map initialized!");

  const mapDiv = document.getElementById("map");
  if (!mapDiv) return;

  const map = new google.maps.Map(mapDiv, {
    center: { lat: 35.681236, lng: 139.767125 }, // 東京駅
    zoom: 10,
    mapId: "DEMO_MAP_ID",
  });

  const currentLocationBtn = document.getElementById("current-location-btn");
  const resultsContainer = document.getElementById("results-container");
  const statusMessage = document.getElementById("search-status-message");
  if (!currentLocationBtn) return;

  // 📍 現在地ボタンがクリックされたとき
  currentLocationBtn.addEventListener("click", async () => {
    console.log("📍 ボタンがクリックされました！");

    // 🟡 検索開始メッセージを表示
    if (statusMessage) {
      statusMessage.textContent =
        "🔍 現在地から遊び場を検索中です…（少し時間がかかる場合があります）";
    }

    if (!navigator.geolocation) {
      alert("このブラウザでは位置情報が利用できません。");
      if (statusMessage) statusMessage.textContent = "";
      return;
    }

    const options = { enableHighAccuracy: true, timeout: 5000, maximumAge: 0 };

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const lat = position.coords.latitude;
        const lng = position.coords.longitude;
        console.log("✅ 現在地取得:", lat, lng);

        const currentPosition = { lat, lng };
        map.setCenter(currentPosition);
        map.setZoom(15);

        // ✅ 現在地マーカー（青丸）
        new google.maps.Marker({
          map,
          position: currentPosition,
          title: "あなたの現在地",
          icon: { url: "https://maps.google.com/mapfiles/ms/icons/blue-dot.png" },
        });

        // ✅ Rails API呼び出し
        const url = `/playgrounds/nearby?lat=${lat}&lng=${lng}`;
        console.log("🌐 Fetching:", url);

        try {
          const res = await fetch(url);
          console.log("📡 API status:", res.status);
          const data = await res.json();
          console.log("🎯 周辺の遊び場データ:", data);

          // ✅ 検索完了メッセージ
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
            // ✅ 徒歩10分（約1km）以内に絞る
            const nearby = data.filter((place) => {
              if (!place.lat || !place.lng) return false;
              const d = getDistanceFromLatLng(lat, lng, place.lat, place.lng);
              return d <= 1000;
            });

            // ✅ 近い順にソート
            const nearbySorted = nearby
              .map((place) => {
                const d = getDistanceFromLatLng(lat, lng, place.lat, place.lng);
                return { ...place, distance: d };
              })
              .sort((a, b) => a.distance - b.distance);

            renderResultsList(nearbySorted);

            // ✅ マーカー生成（赤ピン）
            nearbySorted.forEach((place) => {
              const position = { lat: place.lat, lng: place.lng };

              const marker = new google.maps.Marker({
                map,
                position,
                title: place.name,
                icon: {
                  url: "https://maps.google.com/mapfiles/ms/icons/red-dot.png",
                },
              });

              const photoHtml = place.photo_url
                ? `<img src="${place.photo_url}" alt="${place.name}" class="w-full h-24 object-cover rounded mb-1">`
                : "";

              const ratingHtml = place.rating
                ? `⭐ ${place.rating}（${place.user_ratings_total || 0}件）`
                : "⭐ 評価なし";

              const infoWindow = new google.maps.InfoWindow({
                content: `
                  <div style="max-width:230px">
                    <strong>${place.name}</strong><br>
                    <span>${ratingHtml}</span><br>
                    <small>${place.address || "住所情報なし"}</small><br>
                    ${photoHtml}
                    <a href="https://www.google.com/maps/place/?q=place_id:${place.place_id}"
                       target="_blank" class="text-blue-500 hover:underline">Googleマップで見る</a>
                  </div>
                `,
              });

              marker.addListener("click", () => infoWindow.open(map, marker));
              window.playgroundMarkers.push(marker);
            });
          } else {
            resultsContainer.innerHTML = `
              <p class="text-center text-gray-500 mt-4">
                🎈 近くに遊び場データが見つかりませんでした。
              </p>
            `;
          }
        } catch (err) {
          console.error("❌ Fetchエラー:", err);
          alert("遊び場情報の取得に失敗しました。");
          if (statusMessage) statusMessage.textContent = "";
        }
      },
      (error) => {
        console.error("❌ 位置情報エラー:", error);
        alert("位置情報を取得できませんでした。");
        if (statusMessage) statusMessage.textContent = "";
      },
      options
    );
  });
}

// ✅ 徒歩距離計算
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

// ✅ 結果リスト
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
      </div>
    `
    )
    .join("");
}

// ✅ Turbo対応（描画完了を少し待ってから実行）
document.addEventListener("turbo:load", () => {
  console.log("⚡ turbo:load 発火");
  setTimeout(() => {
    if (typeof google !== "undefined") {
      initMap();
    } else {
      console.warn("⚠️ google undefined");
    }
  }, 300); // ← 300ms待ってから初期化（描画完了を待つ）
});

window.initMap = initMap;
