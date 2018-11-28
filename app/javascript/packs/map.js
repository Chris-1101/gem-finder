import 'mapbox-gl/dist/mapbox-gl.css'
import mapboxgl from 'mapbox-gl/dist/mapbox-gl.js';

const mapElement = document.getElementById('map-background');

if (mapElement) { // only build a map if there's a div#map to inject into
  mapboxgl.accessToken = mapElement.dataset.mapboxApiKey; // API key from `.env`
  const map = new mapboxgl.Map({
    container: 'map-background',
    style: 'mapbox://styles/mapbox/streets-v10'
  });

  const markers = JSON.parse(mapElement.dataset.markers);

  markers.forEach(function(marker) {
    new mapboxgl.Marker()
        .setLngLat([marker.lng, marker.lat])
        .addTo(map);
  });
}


const mapElementShow = document.getElementById('map-background-show');

  if (mapElementShow) { // only build a map if there's a div#map to inject into
    mapboxgl.accessToken = mapElementShow.dataset.mapboxApiKey; // API key from `.env`
    const mapShow = new mapboxgl.Map({
      container: 'map-background-show',
      style: 'mapbox://styles/mapbox/streets-v10'
    });

   const markersShow = JSON.parse(mapElementShow.dataset.markers);

    markersShow.forEach(function(marker) {
      new mapboxgl.Marker()
          .setLngLat([marker.lng, marker.lat])
          .addTo(mapShow);
    });

  if (markersShow.length === 0) {
    mapShow.setZoom(1);
  } else if (markersShow.length === 1) {
    mapShow.setZoom(14);
    mapShow.setCenter([markersShow[0].lng, markersShow[0].lat]);
  } else {
    const bounds = new mapboxgl.LngLatBounds();
    markersShow.forEach((marker) => {
      bounds.extend([marker.lng, marker.lat]);
    });
    mapShow.fitBounds(bounds, { duration: 500, padding: 75 })
  }

  // map.flyTo({
  //   center: [-0.12, 51.49],
  //   offset: [300, 0],
  //   speed: 0.8,
  //   curve: .6
  // });

  // map.setZoom(10.7);
  // map.setCenter([-0.3, 51.52]);
}

const addressInput = document.getElementById('property_address');

if (addressInput) {
  const places = require('places.js');
  const placesAutocomplete = places({
    container: addressInput
  });
}
