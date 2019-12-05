// app/javascript/plugins/init_mapbox.js
import mapboxgl from 'mapbox-gl';
// import polyline from '@mapbox/polyline';


function calculateRoute(map, from, to) {
  const mapElement = document.getElementById('map');

  var lngFrom = from[0]
  var latFrom = from[1]

  var lngTo = to[0]
  var latTo = to[1]

  // $.get('https://api.mapbox.com/directions/v5/mapbox/driving/' + lngFrom + ',' + latFrom + ';' + lngTo + ',' + latTo + '?access_token=' + mapElement.dataset.mapboxApiKey,
  //   function( data ) {
  //   var coords = polyline.decode(data.routes[0].geometry);
  //   var line = L.polyline(coords).addTo(map);
  // });
};


const mapElement = document.getElementById('map');

const buildMap = () => {
  mapboxgl.accessToken = mapElement.dataset.mapboxApiKey;
  return new mapboxgl.Map({
    container: 'map',
    style: 'mapbox://styles/mapbox/streets-v11'
  })
};

const addMarkersToMap = (map, markers) => {
  markers.forEach((marker) => {
    const popup = new mapboxgl.Popup().setHTML(marker.infoWindow);
    new mapboxgl.Marker()
      .setLngLat([ marker.lng, marker.lat ])
      .setPopup(popup)
      .addTo(map);
  });
};


const fitMapToMarkers = (map, markers) => {
  const bounds = new mapboxgl.LngLatBounds();
  markers.forEach(marker => bounds.extend([ marker.lng, marker.lat ]));
  map.fitBounds(bounds, { padding: 70, maxZoom: 12 });
};

const initMapbox = () => {
  if (mapElement) {
    const map = buildMap();
    const markers = JSON.parse(mapElement.dataset.markers);
    addMarkersToMap(map, markers);
    fitMapToMarkers(map, markers);

//--------------------------- START ------------------------------
//-------------- Drawing routes between markers ----------------
    let coordinates = [];
    markers.forEach ((marker) => {
      let coordinate = [];
      coordinate.push(marker.lng);
      coordinate.push(marker.lat);
      coordinates.push(coordinate);
    });

    map.on('load', function () {

      map.addLayer({
        "id": "route",
        "type": "line",
        "source": {
          "type": "geojson",
          "data": {
            "type": "Feature",
            "properties": {},
            "geometry": {
              "type": "LineString",
              "coordinates": coordinates
            }
          }
        },
        "layout": {
          "line-join": "round",
          "line-cap": "round"
        },
        "paint": {
          "line-color": "#81c9ad",
          "line-width": 5,
          'line-opacity': .7
        }
      });
    });
//-------------- Drawing routes between markers ----------------
//--------------------------- END ------------------------------

  }
};
export { initMapbox };
