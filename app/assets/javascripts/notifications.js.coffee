$(document).on 'ready page:load', ->

  get_notifications = () ->

    $.ajax
      url: "/site/notifications"
      dataType: "html"
      error: (jqXHR, textStatus, errorThrown) ->
        $(this).find('#notifications').append "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) =>
        $('#notifications').html(data)
        $('#notifications').foundation('dropdown', 'reflow')


    $.ajax
      url: "/site/updates_count"
      dataType: "html"
      error: (jqXHR, textStatus, errorThrown) ->
        $(this).find('p.notice').append "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) =>
        $('#updates-tab span').html(data)


    setTimeout(get_notifications, 60000)


  setTimeout(get_notifications, 1)