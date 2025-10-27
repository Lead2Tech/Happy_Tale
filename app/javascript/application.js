function initMap() {
  console.log("✅ Google Map initialized!");

  const mapDiv = document.getElementById("map");
  if (!mapDiv) {
    console.warn("🟡 map div not found — skipping map init");
    return;
  }

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
            window.location.href = `/playgrounds?lat=${lat}&lng=${lng}`;
          },
          () => {
            alert("位置情報を取得できませんでした。");
          }
        );
      } else {
        alert("このブラウザでは位置情報が利用できません。");
      }
    });
  } else {
    console.warn("❌ ボタンが見つかりませんでした。");
  }
}

// ✅ Turboに対応（Rails 7）
document.addEventListener("turbo:load", () => {
  console.log("🚀 turbo:load 発火");
  if (typeof google !== "undefined") {
    initMap();
  }
});

window.initMap = initMap;
