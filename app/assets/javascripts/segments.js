
$(window).bind('page:change', function() {
  if (typeof(initializeSegmentMap) == "function" && $('map-canvas').length) {
    initializeSegmentMap();
  }
});

$(window).bind('page:load', function() {
  if (typeof(initializeSegmentMap) == "function" && $('#map-canvas').length) {
    initializeSegmentMap();
  }
});


$(document).ready(function() {
  initializeSegmentMap();
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
  $.each( $('.map-segment-data'), function(key, item) {
    setSegmentTracks(map, item)
  });
}

function setSegmentTracks(map, segment) {
  var title = $(segment).data('name');
  var description = $(segment).data('description');
  var lat = $(segment).data('lat');
  var lng = $(segment).data('lng');
  var alertLevel = $(segment).data('alert-level');
  var icon = ''
  var lineColour = ''


  if (alertLevel == "1") {
    icon = "http://maps.google.com/mapfiles/kml/paddle/wht-circle-lv.png";;
    lineColour = "#777777";
  } else if (alertLevel == "2") {
    icon = "http://maps.google.com/mapfiles/kml/paddle/ylw-circle-lv.png";
    lineColour = "#FFAA00";
  } else {
    icon = "http://maps.google.com/mapfiles/kml/paddle/red-circle-lv.png";
    lineColour = "#FF0000";
  }

  var trackPath = new google.maps.Polyline({
    path: $(segment).data('track'),
    geodesic: true,
    strokeColor: lineColour,
    strokeOpacity: 1.0,
    strokeWeight: 2
  });

  trackPath.setMap(map);

  if ($('#map-marker-data').length == 0) {
    createSegmentMarker(map, title, description, lat, lng, icon);
  }
}

function showIssueMarkers(map) {
  var locationDataContainer = $('#map-marker-data')
  if (locationDataContainer.length > 0 && locationDataContainer.data('locations').length > 0) {
    $.each( locationDataContainer.data('locations'), function(key, location) {
      createMarker(map, location)
    });
  }
}

function createSegmentMarker(map, title, description, lat, lng, icon) {

  zIndex = 1;

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

function createMarker(map, location) {
  var contentString = location[5];

  var infowindow = new google.maps.InfoWindow({
    content: contentString
  });

  var myLatLng = new google.maps.LatLng(location[1], location[2]);

  var marker = new google.maps.Marker({
    position: myLatLng,
    map: map,
    icon: location[4],
    title: location[0],
    zIndex: location[3]
  });
  google.maps.event.addListener(marker, 'click', function() {
    infowindow.open(map,marker);
  });
}



