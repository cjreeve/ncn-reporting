jQuery ->

  $(document).ready ->

    ##### Select the relevant problem dropdown on category change #####
    $('#issue_category_id').on 'change', (e) ->
      $('.category-problems').hide()
      $('.category-problems').find('select').addClass('disabled')
      $('.category-problems').find('select').prop('disabled','disabled')

      categoryOptions = $('#category-'+$(this).find('option:selected').attr('value')+'-problems')
      categoryOptions.show()
      categoryOptions.find('select').removeClass('disabled')
      categoryOptions.find('select').removeAttr('disabled')
      # set the selected value to blank
      if categoryOptions.find('select option:selected').text() == "Other"
        categoryOptions.find('select').val('')
      else
        $('.other-problem-field').hide()

    $('#issue_category_id').trigger('change')


    ##### Show custom field when Other problem is selected
    $('.category-problems-list select').on 'change', (e) ->
      if ($(this).find('option:selected').text() == "Other")
        $('.category-problems').hide()
        $('.other-problem-field').show()

      if ($(this).find('option:selected').text() == '-' and $('#issue_title').val().length > 0)
        $('.category-problems').hide()
        $('.other-problem-field').show()

    $('#issue_problem_id').trigger('change')

    $('#select-problem').on 'click', (e) ->
      e.preventDefault()
      $('#issue_category_id').trigger('change')
      $('.other-problem-field').hide()




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