jQuery ->

  $(document).ready ->

    $('#issue_category_id').on 'change', (e) ->
      $('.category-problems').hide()
      $('.category-problems').find('select').addClass('disabled')
      $('.category-problems').find('select').prop('disabled','disabled')

      categoryOptions = $('#category-'+$(this).find('option:selected').attr('value')+'-problems')
      categoryOptions.show()
      categoryOptions.find('select').removeClass('disabled')
      categoryOptions.find('select').removeAttr('disabled')

    $('#issue_category_id').trigger('change')


    # $('#issue_category_id').on 'loadProblems', (e, categoryId) ->
    #   $.ajax
    #     url: "/categories/"+categoryId+"/problems"
    #     dataType: "html"
    #     error: (jqXHR, textStatus, errorThrown) ->
    #       $(this).find('.input .issue_problem_id').append "AJAX Error: #{textStatus}"
    #     success: (data, textStatus, jqXHR) =>
    #       $('#data-store').html(data)
    #       $('#issue_problem_id').html($('#category_id').html())
    #       $('#data-store').html('')

    # $('#issue_category_id').on 'change', (e) ->
    #   $(this).trigger 'loadProblems', $(this).find('option:selected').attr('value')

    # # ensure the correct problems show on page reload