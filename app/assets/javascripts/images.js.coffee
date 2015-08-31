jQuery ->
  $(document).ready ->

    $('.remove-photo-fields').on 'click', (e) ->
      e.preventDefault();
      console.log('issue_images_attributes_'+$(this).data('image-form-id')+'_id')
      $('#issue_images_attributes_'+$(this).data('image-form-id')+'__destroy').val("true")
      $(this).closest(".image-fields").hide();
