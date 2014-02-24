$(document).ready(function() {
  if ( $('.payment-form-container').length > 0 ) {
    var url = $.url();

    if (url.attr('fragment') == 'payment-form') {

      // Scroll to the payment form
      $('html, body').animate({ scrollTop: $('.payment-form-container').offset().top }, 100);

      // Flash it to get the user's attention
      $('.payment-form-container .panel').highlight();
    }
  }
});
