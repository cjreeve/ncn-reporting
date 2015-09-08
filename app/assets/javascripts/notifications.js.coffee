$(document).on 'ready page:load', ->

  $.ajax
    url: "/site/notifications"
    dataType: "html"
    error: (jqXHR, textStatus, errorThrown) ->
      $(this).find('#notifications').append "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) =>
      $('#notifications').html(data)
      $('#notifications').foundation('dropdown', 'reflow')


