(function( $ ){
  $.fn.highlight = function () {
    $(this).each(function () {
      var el = $(this);
      $("<div/>")
      .width(el.outerWidth())
      .height(el.outerHeight())
      .css({
          "position": "absolute",
          "left": el.offset().left,
          "top": el.offset().top,
          "background-color": "#ffff99",
          "opacity": ".7",
          "z-index": "9999999"
      }).appendTo('body').fadeOut(1000).queue(function () { $(this).remove(); });
    });

    return this;
  };

  $.fn.equalHeight = function() {
    tallest = 0;
    $(this).each(function() {
      thisHeight = $(this).height();
      if(thisHeight > tallest) {
        tallest = thisHeight;
      }
    });
    $(this).height(tallest);

    return this;
  };
})( jQuery );
