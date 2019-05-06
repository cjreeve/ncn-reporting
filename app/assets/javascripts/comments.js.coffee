$(document).on 'ready page:load', ->

  $('#comments').on 'click', ('#cancel-comment-changes'), (e) ->
    e.preventDefault()
    $('.last-comment').slideDown()
    $('.edit-comment-form').fadeOut()
    $('.comment-form').fadeIn()

