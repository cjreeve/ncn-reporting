jQuery ->

  $(document.body).ready ->

    $('article.user input#image_src').on 'change', ->
      $('article.user input#image_src').closest('form').submit()
      $('.profile-image').html('<img class="ajax-loader" alt="loading" src="/images/ajax-loader-fb.gif">')


    $('article.user .reveal-browse-button').on 'click', (e) ->
      e.preventDefault()
      $(this).hide()
      $('article.user #image_src').show()

    $('.user-info-link').hover (e) ->
      $.ajax
        dataType: 'html'
        url: '/users/' + $(this).find('a').data('user-id') + '/user_info'
        error: (jqXHR, textStatus, errorThrown) ->
          # $(this).find('p.notice').append "AJAX Error: #{textStatus}"
        success: (data, textStatus, jqXHR) =>
          $(this).find('.user-info').html(data)
      # $(this).find('.user-info').html("<%= j( render 'users/user_info', user:  ) %>")

