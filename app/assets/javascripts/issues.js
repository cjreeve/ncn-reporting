
$(window).bind('page:change', function() {
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
    // get_current_location_from_browser();
    $('#myCoordModal').foundation('reveal', 'open');
    $(document).on('opened.fndtn.reveal', '[data-reveal]', function () {
      initializeCoordFinder();
    });
  });
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
    // document.getElementById('issue_coordinate').value = lat.toFixed(5) + ", " + lng.toFixed(5);
    $('.searching-location').hide();
  }

  var mapOptions = {
    zoom: zoom,
    center: new google.maps.LatLng(lat, lng)
  };
  coordFinderMap = new google.maps.Map(document.getElementById('coord-map-canvas'),
      mapOptions);

  var bikeLayer = new google.maps.BicyclingLayer();
  bikeLayer.setMap(coordFinderMap);



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
  var crossHairtTmer = setInterval(function(){ myTimer() }, 500);

  function myTimer() {
    get_current_location_from_browser();
    
    if(coordFinderMap && (myCoord !== undefined)) {
      showMyCoord();
      clearInterval(crossHairtTmer);
    }
  };
}

function showMyCoord() {
  // show cross hair
  if(coordFinderMap && myCoord) {
    lat = myCoord.latitude;
    lng = myCoord.longitude;
    crosshairPosition = new google.maps.LatLng(lat, lng);
    crosshairMarker = new google.maps.Marker({
      position: crosshairPosition,
      map: coordFinderMap,
      icon: '/images/crosshair.svg'
    });
    $('.searching-location').hide();
    coordFinderMap.setZoom(17);
    coordFinderMap.panTo(crosshairPosition);
    // if(!myCoordMarker) {
    //   document.getElementById('issue_coordinate').value = lat.toFixed(5) + ", " + lng.toFixed(5);
    // }
  }
}