$(document).ready(function() {
  var coordFinderMap;
  $('#openCoordModal').click(function() {
    $('#myCoordModal').foundation('reveal', 'open');
    $(document).on('opened.fndtn.reveal', '[data-reveal]', function () {
      google.maps.event.addDomListener(window, 'load', initializeCoordFinder());
    });
  });

  function initializeCoordFinder() {
    var mapOptions = {
      zoom: 12,
      center: new google.maps.LatLng(51.517106, -0.113615)
    };
    coordFinderMap = new google.maps.Map(document.getElementById('coord-map-canvas'),
        mapOptions);

    google.maps.event.addListener(coordFinderMap, 'click', function(e) {
      placeMarker(e.latLng, coordFinderMap);
      var theCoord = e.latLng.lat() + ", " + e.latLng.lng()
      document.getElementById('issue_coordinate').value = theCoord;
    });
  };

  function placeMarker(position, map) {
    var marker = new google.maps.Marker({
      position: position,
      map: map
    });
  }

});