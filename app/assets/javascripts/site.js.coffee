jQuery ->

  $(document).ready ->

    $('#close-warning-banner').on 'click', ->

      $('#warning-banner').fadeOut("fast")
