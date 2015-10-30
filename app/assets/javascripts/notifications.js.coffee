$(document).on 'ready page:load', ->

  get_notifications = () ->

    $.ajax
      url: "/site/notifications"
      dataType: "html"
      error: (jqXHR, textStatus, errorThrown) ->
        $(this).find('p.notice').append "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) =>

        dataSmall = data.replace(/nofications-dropdown-key/g, "nofications-dropdown-small")
        $('.site-notifications-small').html(dataSmall)
        $('.site-notifications-small').foundation('dropdown', 'reflow')


        dataLarge = data.replace(/nofications-dropdown-key/g, "nofications-dropdown-large")
        $('.site-notifications-large').html(dataLarge)
        $('.site-notifications-large').foundation('dropdown', 'reflow')


    $.ajax
      url: "/site/updates_count"
      dataType: "html"
      error: (jqXHR, textStatus, errorThrown) ->
        $(this).find('p.notice').append "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) =>
        $('#updates-tab span').html(data)


    setTimeout(get_notifications, 120000)


  get_notifications()
  $('.site-notifications-small').foundation('dropdown', 'reflow')
