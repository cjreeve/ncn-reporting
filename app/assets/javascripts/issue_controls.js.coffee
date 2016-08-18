

jQuery ->

  $(document.body).ready ->

    $('.reporting-prompt').on 'click', '.edit-reporting-prompt', (e) ->
      $(e).preventDefault
      $.ajax
        url: '/administrative_areas/' + $(this).data('administrative-area-id') + '/edit'
        dataType: 'script'
        data: { issue_id: $(this).data('issue-id') }

    $('.reporting-prompt').on 'click', '.cancel-editing-reporting-prompt', ->
      $('.reporting-prompt-url-form').hide()
      $('.reporting-prompt-text').show()
      $('.reporting-prompt').addClass('emphasise');
