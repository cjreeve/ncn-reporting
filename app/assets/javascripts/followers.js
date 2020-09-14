// $(window).bind('page:change', function() {
//   watch_followers_edit_click();
// });

$(document).ready(function() {
  watch_followers_edit_click();
});

function watch_followers_edit_click() {
  $('#edit-followers').click(function(e) {
    e.preventDefault();
    $('#follower-list').hide();
    $('#follower-tokens').fadeIn();
  });

  $('#cancel-issue-follower-update').click(function(e) {
    e.preventDefault();
    $('#follower-tokens').hide();
    $('#follower-list').fadeIn();
  });
}




