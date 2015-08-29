jQuery ->

  $(document).ready ->

    $('a').on 'click', (e) ->
      if(($(this).attr('href') != '#') && ($(this).attr('href') != '/') && ($(this).attr('aria-label') != 'Close'))
        $('#tubolinks-loader').show()