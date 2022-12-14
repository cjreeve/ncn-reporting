jQuery ->

  $(document).ready ->

    $('article.user').on 'change', 'input#image_src', ->
      $('article.user input#image_src').closest('form').submit()
      $('.profile-image').html('<img class="ajax-loader" alt="loading" src="/images/ajax-loader-fb.gif"><br>uploading')


    $('article.user').on 'click', '.reveal-browse-button', (e) ->
      e.preventDefault()
      $(this).hide()
      $('article.user #image_src').show()

    $('.user-info-link').on 'mouseover', (e) ->
      $.ajax
        dataType: 'html'
        url: '/users/' + $(this).find('a').data('user-id') + '/user_info'
        error: (jqXHR, textStatus, errorThrown) ->
          $(this).find('.user-info').html('Error loading user summary')
        success: (data, textStatus, jqXHR) =>
          # $(this).find('.user-info').removeClass('loading')
          $(this).find('.user-info').html(data)

    $('#user_region_id').on 'change', ->
      $.ajax
        dataType: 'html'
        url :'/regions/' + $(this).val() + '/group_options'
        error: (jqXHR, textStatus, errorThrown) ->
          $('#user_group_ids').html('Error loading groups')
        success: (data, textStatus, jqXHR) =>
          $('#user_group_ids').html(data)

