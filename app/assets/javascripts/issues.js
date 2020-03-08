
$(window).bind('page:change', function() {
  if (typeof(initialize) == "function" && $('#map-canvas').length) {
    initialize();
  }
});

$(window).bind('page:load', function() {
  if (typeof(initialize) == "function" && $('#map-canvas').length) {
    initialize();
  }
});


var coordFinderMap;
var myCoord;
var myCoordMarker;
var crosshairPosition;

$(document).ready(function() {

  $('#openCoordModal').click(function() {
    $('#myCoordModal').foundation('reveal', 'open');
    $(document).on('opened.fndtn.reveal', '[data-reveal]', function () {
      initializeCoordFinder();
    });
  });

  $('.publish-issue.disabled').click(function(e) {
    e.preventDefault();
    $('#missing-details-issue-modal').foundation('reveal', 'open');
  });

  // add target='_blank' to banner prompting users to report an issue
  // if ($('.reporting-prompt p a').length > 0){
  //   $('.reporting-prompt p a').attr('target','_blank');
  // }
  $('.edit-reporting-prompt')
});


function get_current_location_from_browser() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      myCoord = position.coords;
    });
  }
}

function initializeCoordFinder() {

  var lat = 51.517106;
  var lng = -0.113615;
  var zoom = 11;

  if (myCoord) {
    lat = myCoord.latitude;
    lng = myCoord.longitude;
    zoom = 17;
    $('.searching-location').hide();
  }

  var mapOptions = {
    zoom: zoom,
    center: new google.maps.LatLng(lat, lng),
    mapTypeId: 'OCM',
    mapTypeControl: false,
    streetViewControl: false,
    disableDefaultUI: true
  };
  coordFinderMap = new google.maps.Map(document.getElementById('coord-map-canvas'),
    mapOptions
  );

  coordFinderMap.mapTypes.set("OCM", new google.maps.ImageMapType({
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

  // var drawingManager = new google.maps.drawing.DrawingManager();
  // drawingManager.setMap(coordFinderMap);

  // var bikeLayer = new google.maps.BicyclingLayer();
  // bikeLayer.setMap(coordFinderMap);



  google.maps.event.addListener(coordFinderMap, 'click', function(e) {
    placeMarker(e.latLng, coordFinderMap);
    var theCoord = e.latLng.lat().toFixed(5) + ", " + e.latLng.lng().toFixed(5)
    document.getElementById('issue_coordinate').value = theCoord;
  });


  if (!myCoord) {
    findMyCoord();
  }
  showMyCoord();

};

function placeMarker(position, map) {
  if (myCoordMarker) {
    myCoordMarker.setMap(null);
  }
  myCoordMarker = new google.maps.Marker({
    position: position,
    map: map
  });
  map.panTo(position);
}

function findMyCoord() {

  if (crossHairtTmer) {
    clearInterval(crossHairtTmer);
  }

  get_current_location_from_browser();
  var crossHairtTmer = setInterval(function(){ myTimer() }, 5000);

  function myTimer() {
    if(coordFinderMap && (myCoord !== undefined)) {
      showMyCoord();
      clearInterval(crossHairtTmer);
    } else {
      get_current_location_from_browser();
    }
  };
}

function showMyCoord() {

  var issue_lat = document.getElementById('coord-data').getAttribute('data-lat');
  var issue_lng = document.getElementById('coord-data').getAttribute('data-lng');

  // show cross hair
  if((issue_lat.length > 0) || (coordFinderMap && myCoord)) {
    if (issue_lat) {
      lat = issue_lat;
      lng = issue_lng;
    } else {
      lat = myCoord.latitude;
      lng = myCoord.longitude;
    }

    crosshairPosition = new google.maps.LatLng(lat, lng);
    crosshairMarker = new google.maps.Marker({
      position: crosshairPosition,
      map: coordFinderMap,
      icon: '/images/crosshair.svg'
    });
    $('.searching-location').hide();
    coordFinderMap.setZoom(17);
    coordFinderMap.panTo(crosshairPosition);
  }
}



// search and results map

$(document).ready(function() {
  $('#add-marker-listener').click(function(event){
    event.preventDefault();

    map.setOptions({ draggableCursor : "url(https://labs.google.com/ridefinder/images/mm_20_white.png) 6 32, auto" })

    google.maps.event.addListener(map, 'click', function(e) {
      placeMarker(e.latLng, map);
      var theCoord = e.latLng.lat().toFixed(5) + ", " + e.latLng.lng().toFixed(5)

      var infowindow = new google.maps.InfoWindow({
        content: theCoord + '<br>' + '<a href="/issues/new?c=' + theCoord + '" >' + 'Create Issue &gt;' + '</a>'
      });
      infowindow.open(map, myCoordMarker);
    });

    $('#add-marker-listener').html('now click map');
    $('#add-marker-listener').delay(2000).fadeOut("slow");

  });
});
