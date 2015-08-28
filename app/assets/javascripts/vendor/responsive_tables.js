var tableSwitched = false;

$(document).ready(function() {

  var updateTables = function() {
    if (($(window).width() < 767) && !tableSwitched ){
      tableSwitched = true;
      $("table.responsive").each(function(i, element) {
        splitTable($(element));
      });
      return true;
    }
    else if (tableSwitched && ($(window).width() > 767)) {
      tableSwitched = false;
      $("table.responsive").each(function(i, element) {
        unsplitTable($(element));
      });
    }
  };

  $(window).load(updateTables);

});


$(window).bind('page:change', function() {

  tableSwitched = false;

  var updateTables = function() {
    if (($(window).width() < 767) && !tableSwitched ){
      tableSwitched = true;
      $("table.responsive").each(function(i, element) {
        splitTable($(element));
        console.log('here');
      });
      return true;
    }
    else if (tableSwitched && ($(window).width() > 767)) {
      tableSwitched = false;
      $("table.responsive").each(function(i, element) {
        unsplitTable($(element));
      });
    }
  };

  if (!tableSwitched) {
    updateTables();
  }

});


function splitTable(original)
{
  original.wrap("<div class='table-wrapper' />");

  var copy = original.clone();
  copy.find("td:not(:first-child), th:not(:first-child)").css("display", "none");
  copy.removeClass("responsive");

  original.closest(".table-wrapper").append(copy);
  copy.wrap("<div class='pinned' />");
  original.wrap("<div class='scrollable' />");

  setCellHeights(original, copy);
}

function unsplitTable(original) {
  original.closest(".table-wrapper").find(".pinned").remove();
  original.unwrap();
  original.unwrap();
}

function setCellHeights(original, copy) {
  var tr = original.find('tr'),
      tr_copy = copy.find('tr'),
      heights = [];

  tr.each(function (index) {
    var self = $(this),
        tx = self.find('th, td');

    tx.each(function () {
      var height = $(this).outerHeight(true);
      heights[index] = heights[index] || 0;
      if (height > heights[index]) heights[index] = height;
    });

  });

  tr_copy.each(function (index) {
    $(this).height(heights[index]);
  });
}