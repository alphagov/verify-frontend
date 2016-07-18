
(function () {
  "use strict";
  var root = this,
    $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var furtherInformation = {
        toggleValidation: function () {
            var $sumbitButton = furtherInformation.$form.find('input#cycle_three_submit[type=submit]');
            if (!furtherInformation.$form.find('#cycle_three_form_null_attribute').prop('checked')) {
                $sumbitButton.removeAttr("formnovalidate")
            } else {
                $sumbitButton.attr("formnovalidate", "formnovalidate")
            }
        },
        init: function () {
            furtherInformation.$form = $('#further-information');
            if(furtherInformation.$form.length === 1) {
                furtherInformation.$form.find('#cycle_three_form_null_attribute').on('click', furtherInformation.toggleValidation);
                furtherInformation.$form.validate();
            }
        }
    };

  root.GOVUK.furtherInformation = furtherInformation;
}).call(this);