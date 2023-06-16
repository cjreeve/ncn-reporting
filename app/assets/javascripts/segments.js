$(document).ready(function() {
  if ($('#map-canvas').length > 0) {
    initializeSegmentMap();
  }
});

function initializeSegmentMap() {
  var mapCanvas = $('#map-canvas');
  var mapCenter = new google.maps.LatLng(mapCanvas.data('lat'), mapCanvas.data('lng'));
  var mapZoom = mapCanvas.data('zoom');
  var mapOptions = { zoom: mapZoom, center: mapCenter };
  var map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);


  showTracks(map);
  showIssueMarkers(map);
}

function showTracks(map) {
  $.each( $('.map-segment-data'), function(index, item) {
    setSegmentTrack(map, item, index)
  });
}

function setSegmentTrack(map, segment, index) {
  var title = $(segment).data('name');
  var description = $(segment).data('description');
  var lat = $(segment).data('lat');
  var lng = $(segment).data('lng');
  var alertLevel = $(segment).data('alert-level');
  var icon = ''
  var lineColour = ''


  if (alertLevel == "1") {
    icon = "http://maps.google.com/mapfiles/kml/paddle/grn-circle-lv.png";
    lineColour = "#00FF77";
  } else if (alertLevel == "2") {
    icon = "http://maps.google.com/mapfiles/kml/paddle/2-lv.png";
    lineColour = "#FF8800";
  } else if (alertLevel == "3") {
    icon = "http://maps.google.com/mapfiles/kml/paddle/3-lv.png";
    lineColour = "#FF6600";
  } else if (alertLevel == "4") {
    icon = "http://maps.google.com/mapfiles/kml/paddle/4-lv.png";
    lineColour = "#FF4400";
  } else if (alertLevel == "5") {
    icon = "http://maps.google.com/mapfiles/kml/paddle/5-lv.png";
    lineColour = "#FF2200";
  } else if (alertLevel == "6") {
    icon = "http://maps.google.com/mapfiles/kml/paddle/6-lv.png";
    lineColour = "#FF0000";
  } else {
    icon = "http://maps.google.com/mapfiles/kml/paddle/purple-circle-lv.png";
    lineColour = "#8800FF";
  }

  var trackPath = new google.maps.Polyline({
    path: $(segment).data('track'),
    geodesic: true,
    strokeColor: lineColour,
    strokeOpacity: 1.0,
    strokeWeight: 2
  });

  trackPath.setMap(map);
  google.maps.event.addListener(trackPath, 'click', function() {
    setTrackColor(trackPath, '#00FFaa');
    setTimeout(function() {
      setTrackColor(trackPath, lineColour);
    }, 1500);
  });

  if ($('#map-marker-data').length == 0) {
    createSegmentMarker(map, title, description, lat, lng, icon, index);
  }
}

function setTrackColor(trackPath, color) {
  trackPath.setOptions({strokeColor: color});
}

function createSegmentMarker(map, title, description, lat, lng, icon, index) {

  var infowindow = new google.maps.InfoWindow({
      content: description
  });

  var myLatLng = new google.maps.LatLng(lat, lng);

  var markerIcon = {
    url: icon,
    scaledSize: new google.maps.Size(16, 16),
    anchor: new google.maps.Point(8,8),
    title: title,
    zIndex: index
  }

  var marker = new google.maps.Marker({
    position: myLatLng,
    map: map,
    icon: markerIcon
  });

  google.maps.event.addListener(marker, 'click', function() {
    infowindow.open(map,marker);
  });
}



