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

      $("#issue-modal-images").owlCarousel({
        singleItem: true,
        navigation: true,
        navigationText: false,
        pagination: true,
        mouseDrag: true,
        touchDrag: true
      });

    });
