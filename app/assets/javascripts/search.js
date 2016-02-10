var myCoord;

$(document).ready(function() {

  function get_current_location_from_browser() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function(position) {
        myCoord = position.coords;
      });
    }
  }

  function findMyCoord() {
    var crossHairtTmer = setInterval(function(){ myTimer() }, 500);

    function myTimer() {
      get_current_location_from_browser();

      if(myCoord !== undefined) {
        var coord_string = myCoord.latitude.toFixed(5) + ", " + myCoord.longitude.toFixed(5);
        $('input#q').val(coord_string);
        $('#search-location-button').closest('form').submit();
      }
    };
  }

  $('#search-location-button').click(function(event){
    if ($('input#q').val().length == 0) {
      event.preventDefault();
      if (!myCoord) {
        findMyCoord();
      }
    }
  });
});
