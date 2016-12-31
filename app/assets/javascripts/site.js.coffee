jQuery ->

  $(document).ready ->

    $('#close-warning-banner').on 'click', ->

      $('#warning-banner').fadeOut("fast")

    $('.search-option input#query').on 'input', ->
      $(this).closest('form').submit();

    $('.clear-text-field').on 'click', (e) ->
      e.preventDefault()
      $(this).parent().find('input[type="text"]').val('')
      $(this).closest('form').submit()

    $('.filter-checkboxes input').on 'change', ->
      $(this).closest('form').submit()
