jQuery ->

  $(document).ready ->

    if $('.issue-filters').length > 0

      $('.issue-filters select').on 'change', ->

        $(this).closest('form').submit();