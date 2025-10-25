function initMap() {
  console.log("✅ Google Map initialized!");

  const mapDiv = document.getElementById("map");
  if (!mapDiv) {
    console.warn("🟡 map div not found — skipping map init");
    return;
  }

  const playgrounds = JSON.parse(mapDiv.dataset.playgrounds || "[]");
  console.log("🔍 playgrounds data:", playgrounds);

  const map = new google.maps.Map(mapDiv, {
    center: { lat: 35.681236, lng: 139.767125 },
    zoom: 10,
  });

  const geocoder = new google.maps.Geocoder();
  const bounds = new google.maps.LatLngBounds();

  const promises = playgrounds.map(pg => {
    console.log("Geocoding:", pg.name, pg.address);
    return new Promise(resolve => {
      if (!pg.address) {
        console.warn("⚠️ No address for playground:", pg);
        return resolve();
      }

      geocoder.geocode({ address: pg.address }, (results, status) => {
        console.log("Geocode result for", pg.address, status, results);
        if (status === "OK" && results[0]) {
          const position = results[0].geometry.location;
          new google.maps.Marker({
            position,
            map,
            title: pg.name,
          });
          bounds.extend(position);
        }
        resolve();
      });
    });
  });

  Promise.all(promises).then(() => {
    console.log("✅ All geocoded, bounds:", bounds);
    if (!bounds.isEmpty()) {
      map.fitBounds(bounds);
      console.log("✅ fitBounds applied");
    } else {
      console.warn("⚠️ bounds is empty — cannot fit bounds");
    }
  });
}

document.addEventListener("turbo:load", () => {
  if (typeof google !== "undefined") {
    initMap();
  }
});
window.initMap = initMap;
