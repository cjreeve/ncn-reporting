$(document).ready(function() {
  var coordFinderMap;
  var myCoord;
  var myCoordMarker;

  $('#openCoordModal').click(function() {
    get_current_location_from_browser();
    $('#myCoordModal').foundation('reveal', 'open');
    $(document).on('opened.fndtn.reveal', '[data-reveal]', function () {
      google.maps.event.addDomListener(window, 'load', initializeCoordFinder());
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
      document.getElementById('issue_coordinate').value = lat.toFixed(5) + ", " + lng.toFixed(5);
    }

    var mapOptions = {
      zoom: zoom,
      center: new google.maps.LatLng(lat, lng)
    };
    coordFinderMap = new google.maps.Map(document.getElementById('coord-map-canvas'),
        mapOptions);

    if (myCoord) {
      // show crosshair
      var crosshairPosition = new google.maps.LatLng(lat, lng);
      crosshairMarker = new google.maps.Marker({
        position: crosshairPosition,
        map: coordFinderMap,
        icon: '/images/crosshair.svg'
      });
    }

    // var bikeLayer = new google.maps.BicyclingLayer();
    // bikeLayer.setMap(coordFinderMap);

    google.maps.event.addListener(coordFinderMap, 'click', function(e) {
      placeMarker(e.latLng, coordFinderMap);
      var theCoord = e.latLng.lat().toFixed(5) + ", " + e.latLng.lng().toFixed(5)
      document.getElementById('issue_coordinate').value = theCoord;
    });
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

});