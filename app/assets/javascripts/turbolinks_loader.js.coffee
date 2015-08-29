$(document).on "page:fetch", (e) ->
  $('#tubolinks-loader').css('top', ($('header').height() + 5 + 'px'))
  $('#tubolinks-loader').show()


$(document).on 'page:receive', (e) ->
  $('#tubolinks-loader').hide()
