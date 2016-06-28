//= require vendor/jquery.inputevent

(function () {
  "use strict";
  var root = this,
    $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  /**
   * The reply radios need special treatment because unlike
   * most other radios on verify they cohabit with textareas
   * and inputs.
   */
  function placeReplyRadioErrorMessage($element, $error) {
    if ($element.attr('name') === 'feedback_form[reply]') {
      var $replyFieldset = $element.closest('.form-group');
      $replyFieldset.children('.error-message').remove();
      $replyFieldset.prepend($error);
    }
  }

  var feedback = {
    toggleReply: function () {
      var requiresReply = feedback.$replyRadios.filter(':checked').val() === 'true';
      if (requiresReply) {
        feedback.$replyFields.removeClass('js-hidden');
      } else {
        feedback.$replyFields.addClass('js-hidden');
        feedback.validator.resetForm();
      }
    },
    init: function () {
      feedback.$form = $('#feedback');
      feedback.$replyRadios = $('input[name="feedback_form[reply]"]');
      feedback.$replyFields = $('.reply-fields');

      if (feedback.$form.length === 1) {
        feedback.$replyRadios.on('click', feedback.toggleReply);
        feedback.validator = feedback.$form.validate({
          errorPlacement: function ($error, $element) {
            $.validator.defaults.errorPlacement($error, $element);
            placeReplyRadioErrorMessage($element, $error);
          }
        });
        feedback.$form.find('#feedback_form_js_disabled').val(false);
        feedback.toggleReply();
        feedback.initCounters();
      }
    },
    initCounters: function () {
      $('.counted').each(function (index) {
        $(this).on('txtinput', function () {
          feedback.handleCounter(this);
        });
      });
    },
    handleCounter: function (counted) {
      var counterId = '#' + counted.id + '_counter';
      var limit = counted.getAttribute('data-rule-maxlength');
      var message = counted.getAttribute('data-msg');
      $(counterId).html((limit - counted.value.length) + message);
    }
  };

  root.GOVUK.feedback = feedback;
}).call(this);
