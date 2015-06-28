$(document).ready(function() {
  var coordFinderMap;
  var myCoord;
  var myCoordMarker;

  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      myCoord = position.coords;
      // myLat = position.coords.latitude;
      // myLng = position.coords.longitude;
    });
  } 

  $('#openCoordModal').click(function() {
    $('#myCoordModal').foundation('reveal', 'open');
    $(document).on('opened.fndtn.reveal', '[data-reveal]', function () {
      google.maps.event.addDomListener(window, 'load', initializeCoordFinder());
    });
  });

  function initializeCoordFinder() {

    var lat = 51.517106;
    var lng = -0.113615;

    if (myCoord) {
      lat = myCoord.latitude;
      lng = myCoord.longitude;
    } 

    var mapOptions = {
      zoom: 16,
      center: new google.maps.LatLng(lat, lng)
    };
    coordFinderMap = new google.maps.Map(document.getElementById('coord-map-canvas'),
        mapOptions);

    // var bikeLayer = new google.maps.BicyclingLayer();
    // bikeLayer.setMap(coordFinderMap);

    google.maps.event.addListener(coordFinderMap, 'click', function(e) {
      placeMarker(e.latLng, coordFinderMap);
      var theCoord = e.latLng.lat() + ", " + e.latLng.lng()
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