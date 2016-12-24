jQuery ->

  $(document).ready ->

    $('#close-warning-banner').on 'click', ->

      $('#warning-banner').fadeOut("fast")

    $('.search-option input#query').on 'input', ->
      $(this).closest('form').submit();
