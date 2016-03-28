
$(function() {
  $("#user_administrative_area_tokens").tokenInput("/administrative_areas.json", {
    crossDomain: false,
    prePopulate: $("#user_administrative_area_tokens").data("pre")
  });

  $("#issue_route_id").tokenInput("/routes.json", {
    crossDomain: false,
    prePopulate: $("#issue_route_id").data("pre"),
    tokenLimit: 1
  });
});
