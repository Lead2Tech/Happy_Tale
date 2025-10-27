function initMap() {
  console.log("✅ Google Map initialized!");

  const mapDiv = document.getElementById("map");
  if (!mapDiv) return;

  const map = new google.maps.Map(mapDiv, {
    center: { lat: 35.681236, lng: 139.767125 },
    zoom: 10,
  });

  // 📍 現在地ボタンのクリックイベント
  const currentLocationBtn = document.getElementById("current-location-btn");
  if (currentLocationBtn) {
    currentLocationBtn.addEventListener("click", () => {
      console.log("📍 ボタンがクリックされました！");
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
          (position) => {
            const lat = position.coords.latitude;
            const lng = position.coords.longitude;
            console.log("✅ 現在地取得:", lat, lng);

            // ✅ 現在地を中心にズーム
            const currentPosition = { lat: lat, lng: lng };
            map.setCenter(currentPosition);
            map.setZoom(15); // 🔍 ズームレベル（値を大きくするとより近く）

            // ✅ 現在地にマーカーを追加
            new google.maps.Marker({
              position: currentPosition,
              map,
              title: "あなたの現在地",
              icon: {
                path: google.maps.SymbolPath.CIRCLE,
                scale: 8,
                fillColor: "#4285F4",
                fillOpacity: 1,
                strokeWeight: 2,
                strokeColor: "#ffffff",
              },
            });

            // ✅ Rails側へリロードして周辺検索
            window.location.href = `/playgrounds?lat=${lat}&lng=${lng}`;
          },
          (error) => {
            console.error("❌ 位置情報エラー:", error);
            alert("位置情報を取得できませんでした。");
          }
        );
      } else {
        alert("このブラウザでは位置情報が利用できません。");
      }
    });
  }
}

// ✅ Turbo対応
document.addEventListener("turbo:load", () => {
  console.log("🚀 turbo:load 発火");
  if (typeof google !== "undefined") {
    initMap();
  }
});

window.initMap = initMap;
