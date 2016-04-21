(function() {
  'use strict';

  var root = this,
    $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var dialog = {
    init: function () {
      // Trap focus for dialogs
      $("dialog").trap();

      // Dialogs
      $('.js-dialog').on('click', function (e) {
        e.preventDefault();

        var $clickedLink = $(this);
        var dialogId = $clickedLink.attr('href').split('#')[1];
        var $dialog = $("#" + dialogId);

        // Add ARIA attributes
        $dialog
          .attr({
            'tabindex': '-1',
            'open': 'true',
            'role': 'dialog'
          });

        // Add a close button
        $dialog.append('<a href="#" class="dialog-close js-dialog-close" role="button">close</a>');

        // Add an translucent background
        var $dialogBackdrop = $('<div class="dialog-backdrop"></div>');
        $('body').prepend($dialogBackdrop);

        // Show the modal
        $dialog.show();

        // Trap focus on the modal
        $dialog.focus();

        // Scroll to top
        $(window).scrollTop(0);

        var $globalHeaderFooter = $('#global-header, #footer');
        // Prevent interaction with the main content area
        $globalHeaderFooter.attr('aria-hidden', 'true');

        var $close = $dialog.find(".js-dialog-close");

        var closeDialog = function () {
          // Remove close button
          $close.remove();
          // remove dialog attributes and empty dialog
          $dialog.removeAttr('open role aria-labelledby tabindex');
          // Hide dialog
          $dialog.hide();
          // Hide backdrop
          $('.dialog-backdrop').remove();
          // Allow interaction with main content area
          $globalHeaderFooter.attr('aria-hidden', 'false');
          // Return focus to trigger
          $clickedLink.focus();
        };

        // run closeDialog() on click of background
        $dialogBackdrop.on('click', function () {
          closeDialog();
        });

        // run closeDialog() on click of close button
        $close.on('click', function () {
          closeDialog();
        });

        // also run closeDialog() on ESC
        $(document).keyup(function (e) {
          if (e.keyCode === 27) {
            closeDialog();
          }
        });
      });
    }
  };

  root.GOVUK.dialog = dialog;
}).call(this);
