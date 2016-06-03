(function () {
  "use strict";
  var root = this,
    $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var feedback = {
    toggleReply: function() {
      var requiresReply = feedback.$replyRadios.filter(':checked').val() === 'true';
      if (requiresReply) {
        feedback.$replyFields.removeClass('js-hidden');
      } else {
        feedback.$replyFields.addClass('js-hidden');
        feedback.validator.resetForm();
      }
    },
    init: function (){
      feedback.$form = $('#feedback');
      feedback.$replyRadios = $('input[name="feedback_form[reply]"]');
      feedback.$replyFields = $('.reply-fields');

      if (feedback.$form.length === 1) {
        feedback.$replyRadios.on('click',feedback.toggleReply);
        feedback.toggleReply();
        feedback.validator = feedback.$form.validate({
          errorPlacement: null,
          rules: {
            'feedback_form[name]': 'required',
            'feedback_form[email]': 'required'
          }
        });
        feedback.$form.find('#feedback_form_js_disabled').val(false);
      }
    }
  };

  root.GOVUK.feedback = feedback;
}).call(this);
