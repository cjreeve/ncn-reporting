jQuery ->

  $(document).ready ->

    $('a').on 'click', (e) ->
      if(($(this).attr('href') != '#') && ($(this).attr('href') != '/'))
        $('#tubolinks-loader').show()