
$(window).bind('page:change', function() {
  if (typeof(initializeSegmentMap) == "function" && $('#segment-map-canvas').length) {
    initializeSegmentMap();
  }
});

$(window).bind('page:load', function() {
  if (typeof(initializeSegmentMap) == "function" && $('#segment-map-canvas').length) {
    initializeSegmentMap();
  }
});

$(document).ready(function() {
  initializeSegmentMap();
});

function initializeSegmentMap() {
  mapCanvas = $('#segment-map-canvas');
  title = mapCanvas.data('name');
  description = mapCanvas.data('description');
  lat = mapCanvas.data('lat');
  lng = mapCanvas.data('lng');
  alertLevel = mapCanvas.data('alert-level');
  mapCenter = new google.maps.LatLng(lat, lng);

  mapOptions = {
    zoom: 12,
    center: mapCenter
  }

  if (alertLevel == "1") {
    icon = "http://maps.google.com/mapfiles/kml/pal4/icon57.png";;
    lineColour = "#777777";
  } else if (alertLevel == "2") {
    icon = "http://maps.google.com/mapfiles/kml/pal3/icon41.png";
    lineColour = "#FFAA00";
  } else {
    icon = "http://maps.google.com/mapfiles/kml/pal3/icon51.png";
    lineColour = "#FF0000";
  }

  map = new google.maps.Map(document.getElementById('segment-map-canvas'), mapOptions);

  var trackPath = new google.maps.Polyline({
    path: $('#segment-map-canvas').data('track'),
    geodesic: true,
    strokeColor: lineColour,
    strokeOpacity: 1.0,
    strokeWeight: 2
  });

  trackPath.setMap(map);



  createSegmentMarker(map, title, description, lat, lng, icon);
}

function createSegmentMarker(map, title, description, lat, lng, icon) {

  zIndex = 10000;

  infowindow = new google.maps.InfoWindow({
      content: description
  });

  myLatLng = new google.maps.LatLng(lat, lng);

  marker = new google.maps.Marker({
      position: myLatLng,
      map: map,
      icon: icon,
      title: title,
      zIndex: zIndex
  });
  google.maps.event.addListener(marker, 'click', function() {
    infowindow.open(map,marker);
  });
}


