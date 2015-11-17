    $(document).ready(function() {

      $("#issue-page-images").owlCarousel({
        singleItem: true,
        autoPlay: 3500,
        // transitionStyle : "fade",
        navigation: true,
        navigationText: false,
        pagination: true,
        mouseDrag: true,
        touchDrag: true
      });

      var issueModalImages = $("#issue-modal-images").owlCarousel({
        singleItem: true,
        navigation: true,
        navigationText: false,
        pagination: true,
        mouseDrag: true,
        touchDrag: true
      });

      $('#issue-page-images .issue-image-container img').on('click', function(){
        var index = $(this).data('index');
        issueModalImages.trigger('owl.goTo', index);
      });

    });
