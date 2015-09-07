jQuery ->

  $(document).ready ->

    $.ajax
      url: "/site/notifications"
      dataType: "html"
      error: (jqXHR, textStatus, errorThrown) ->
        $(this).find('#notifications').append "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) =>
        $('#notifications').html(data)

