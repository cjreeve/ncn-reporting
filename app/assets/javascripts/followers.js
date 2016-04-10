$(window).bind('page:change', function() {
  watch_followers_edit_click();
});

$(window).bind('page:load', function() {
  watch_followers_edit_click();
});

function watch_followers_edit_click() {
  $('#edit-followers').click(function(e) {
    e.preventDefault();
    $('#follower-list').hide();
    $('#follower-tokens').fadeIn();
  });
}




