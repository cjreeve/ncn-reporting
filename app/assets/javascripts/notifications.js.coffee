$(document).ready ->

  get_notifications = () ->

    today = new Date().getHours();

    # avoid JS keeping server awake between 1 - 7am
    if (today <= 1 || today >= 7)
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


    setTimeout(get_notifications, 60000)


  if $('#controls-cog').is(":visible") && $('.show-notifications').length > 0
    get_notifications()
    $('.site-notifications-small').foundation('dropdown', 'reflow')

