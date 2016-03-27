
$(function() {
  $("#user_administrative_area_tokens").tokenInput("/administrative_areas.json", {
    crossDomain: false,
    prePopulate: $("#user_administrative_area_tokens").data("pre")
  });
});
