$(document).ready(function() {
  $('.timeago').timeago();

  if ( $('.payment-form-container').length > 0 ) {
    var url = $.url();

    if (url.attr('fragment') == 'payment-form') {

      // Scroll to the payment form
      $('html, body').animate({ scrollTop: $('.payment-form-container').offset().top }, 100);

      // Flash it to get the user's attention
      $('.payment-form-container .panel').highlight();
    }

    $('#pay-default-card').click( function() {
      $(this).find('form').submit();
    });

    $('#pay-new-card').click( function() {
      $('#payment-options').addClass('hidden');
      $('#payment-form').removeClass('hidden');
    });
  }

  $('.settings-publisher .show-new-card-form').click(function() {
    $(this).addClass('hidden');
    $('.settings-publisher .form-card-new').removeClass('hidden');
  });

  $('.settings-publisher .account-overview .panel').equalHeight();

  $('.single-post-compare').prettyTextDiff({
    originalContainer: '.original-post .heading-original',
    changedContainer: '.edited-post .heading-changed',
    diffContainer: '.diff-post .heading-diff',
    cleanup: true
  });

  $('.single-post-compare').prettyTextDiff({
    originalContainer: '.original-post .body-original',
    changedContainer: '.edited-post .body-changed',
    diffContainer: '.diff-post .body-diff',
    cleanup: true
  });
});
