
$(document).ready(function() {
  if ($('#map-canvas-ocm').length > 0) {
    initializeOcmMap();
  }
  // $(document).foundation();
  // $(document).foundation('dropdown', 'reflow');
});


var ocmMap;
var myCoord;
var myCoordMarker;

$(document).ready(function() {
  $('#openCoordModal').click(function() {
    $('#myCoordModal').foundation('reveal', 'open');
    $(document).on('opened.fndtn.reveal', '[data-reveal]', function () {
      initializeOcmMap();
    });
  });

  $('.publish-issue.disabled').click(function(e) {
    e.preventDefault();
    $('#missing-details-issue-modal').foundation('reveal', 'open');
  });
});

function get_current_location_from_browser() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      myCoord = position.coords;
    });
  }
}

function initializeOcmMap() {

  var canvas = $('#map-canvas-ocm');

  if (canvas.data('lng') == undefined || canvas.data('lng').length == 0) {
    lat = canvas.data('region-lat');
    lng = canvas.data('region-lng');
    findMyCoord();
  } else {
    var lat = canvas.data('lat');
    var lng = canvas.data('lng');
  }
  var zoom = canvas.data('zoom');;

  var mapOptions = {
    zoom: zoom,
    center: new google.maps.LatLng(lat, lng),
    mapTypeId: 'OCM',
    mapTypeControl: false,
    streetViewControl: false,
    disableDefaultUI: true
  };

  if (ocmMap == undefined) {
    ocmMap = new google.maps.Map(document.getElementById('map-canvas-ocm'),
      mapOptions
    );
  }

  ocmMap.mapTypes.set("OCM", new google.maps.ImageMapType({
    getTileUrl: function(coord, zoom) {
      // "Wrap" x (logitude) at 180th meridian properly
      var tilesPerGlobe = 1 << zoom;
      var x = coord.x % tilesPerGlobe;
      if (x < 0) x = tilesPerGlobe+x;
      return "https://tile.thunderforest.com/cycle/" + zoom + "/" + x + "/" + coord.y + ".png?apikey=78f1eea50a5a47e5a576d30f13fed26e";
    },
    tileSize: new google.maps.Size(256, 256),
    name: "OpenStreetMap",
    maxZoom: 18
  }));


  if (canvas.data('type') == 'edit') {
    crossHairMarker(ocmMap, lat, lng)
    addCoordinateOnClick(ocmMap);

  } else if (canvas.data('type') == 'new') {
    findMyCoord(ocmMap);
    addCoordinateOnClick(ocmMap);

  } else if (canvas.data('type') == 'show') {
    position = new google.maps.LatLng(lat, lng);
    placeMarker(position, ocmMap)
  } else if (canvas.data('type') == 'search') {
    position = new google.maps.LatLng(lat, lng);
    crossHairMarker(ocmMap, lat, lng)
  }

  if ($('#map-marker-data').length > 0) {
    showIssueMarkers(ocmMap);
  }

  if($('#add-marker-listener').length > 0){
    $('#add-marker-listener').fadeIn(3000);
  }
};

// Issue edit
function addCoordinateOnClick(map) {
  google.maps.event.addListener(map, 'click', function(e) {
    placeMarker(e.latLng, map);
    var newCoord = e.latLng.lat().toFixed(5) + ", " + e.latLng.lng().toFixed(5)
    $('#issue_coordinate').val(newCoord);
  });
}

function placeMarker(position, map) {
  var icon = "https://maps.google.com/mapfiles/ms/icons/pink.png"
  if (myCoordMarker) {
    myCoordMarker.setMap(null);
  }
  myCoordMarker = new google.maps.Marker({
    position: position,
    icon: icon,
    map: map
  });
  map.panTo(position);
}

function crossHairMarker(map, lat, lng) {
  var crosshairPosition = new google.maps.LatLng(lat, lng);
  crosshairMarker = new google.maps.Marker({
    position: crosshairPosition,
    map: map,
    icon: '/images/crosshair.svg'
  });
}

function findMyCoord(map) {
  $('.searching-location').removeClass('hidden')

  if (crossHairtTmer) {
    clearInterval(crossHairtTmer);
  }

  get_current_location_from_browser();
  var crossHairtTmer = setInterval(function(){ myTimer() }, 5000);

  function myTimer() {
    if(map && (myCoord !== undefined)) {
      showMyCoord(map, myCoord);
      clearInterval(crossHairtTmer);
    } else {
      get_current_location_from_browser();
    }
  };
}

function showMyCoord(map, myCoord) {
  $('.searching-location').addClass('hidden')
  crossHairMarker(map, myCoord.latitude, myCoord.longitude)
  var position = new google.maps.LatLng(myCoord.latitude, myCoord.longitude);
  map.panTo(position);
}

// used by any map that shows issue markers
function showIssueMarkers(map) {
  var locationDataContainer = $('#map-marker-data')
  if (locationDataContainer.length > 0 && locationDataContainer.data('locations').length > 0) {
    $.each( locationDataContainer.data('locations'), function(key, location) {
      createMarker(map, location)
    });
  }
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

// search and results map
$(document).ready(function() {
  $('#add-marker-listener').click(function(event){
    event.preventDefault();

    ocmMap.setOptions({ draggableCursor : "url(https://labs.google.com/ridefinder/images/mm_20_white.png) 6 32, auto" })

    google.maps.event.addListener(ocmMap, 'click', function(e) {
      placeMarker(e.latLng, ocmMap);
      var theCoord = e.latLng.lat().toFixed(5) + ", " + e.latLng.lng().toFixed(5)

      var infowindow = new google.maps.InfoWindow({
        content: theCoord + '<br>' + '<a href="/issues/new?c=' + theCoord + '" >' + 'Create Issue &gt;' + '</a>'
      });
      infowindow.open(ocmMap, myCoordMarker);
    });

    $('#add-marker-listener').html('now click map');
    $('#add-marker-listener').delay(2000).fadeOut("slow");

  });
});
