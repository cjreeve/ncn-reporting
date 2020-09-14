$(document).ready ->

  $('#comments').on 'click', ('#cancel-comment-changes'), (e) ->
    e.preventDefault()
    $('.last-comment').slideDown()
    $('.edit-comment-form').fadeOut()
    $('.comment-form').fadeIn()

  $('article.issue').on 'click', '.upload-icon', (e) ->
    $(this).hide()
    $('.comment_image_src').fadeIn()

