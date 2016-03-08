
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

    map.setOptions({ draggableCursor : "url(http://labs.google.com/ridefinder/images/mm_20_white.png) 6 32, auto" })

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


