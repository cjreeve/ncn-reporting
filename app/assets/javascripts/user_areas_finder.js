
var areaFinderMap;
var userRouteLines;


$(document).ready(function() {

  function wait(ms){
     var start = new Date().getTime();
     var end = start;
     while(end < start + ms) {
       end = new Date().getTime();
    }
  }

  $('.areas-finder-modal-link').click(function() {
    $('#areasFinderModal').foundation('reveal', 'open');

    // $(document).on('opened.fndtn.reveal', '[data-reveal]', function () {
      wait(1000);

      $('html,body').animate({
         scrollTop: $("#areasFinderModal").offset().top
      });

      // $('#areasFinderModal').css('top', '10px');
      initializeAreaFinder();
      // $('#areasFinderModal').css('height', '600px');
    // });
  });

});


function initializeAreaFinder() {

  var lat = 51.520058;
  var lng =  -0.103112;
  var zoom = 11;

  var mapOptions = {
    zoom: zoom,
    center: new google.maps.LatLng(lat, lng),
    mapTypeId: 'OCM',
    mapTypeControl: false,
    streetViewControl: false
  };
  areaFinderMap = new google.maps.Map(
    document.getElementById('areas-map-canvas'),
    mapOptions
  );

  areaFinderMap.mapTypes.set("OCM", new google.maps.ImageMapType({
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

  var drawingManager = new google.maps.drawing.DrawingManager({
    drawingMode: google.maps.drawing.OverlayType.POLYLINE,
    drawingControl: true,
    drawingControlOptions: {
      position: google.maps.ControlPosition.TOP_CENTER,
      drawingModes: ['polyline']
    }
  });
  drawingManager.setMap(areaFinderMap);

  google.maps.event.addListener(drawingManager, 'polylinecomplete', function(line) {
    // alert(line.getPath().getArray().toString());
    userRouteLines = line.getPath().getArray();
    // JSON.stringify

    $.ajax({
      type: "GET",
      data: {coords: JSON.stringify(userRouteLines)},
      dataType: 'json',
      url: "/user/route_areas",
      success: function(results) {
        // $('.answer').html(results);
        // $("#user_administrative_area_tokens").populate_dropdown(query, results)
        // var query = 'none';
        $.each(results, function(i, item) {
          $("#user_administrative_area_tokens").tokenInput("add", item);
        });
      }
    });
  });

};
