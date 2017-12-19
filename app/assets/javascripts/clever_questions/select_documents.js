(function (global) {
    "use strict";
    var GOVUK = global.GOVUK || {};
    var $ = global.jQuery;

    var selectDocuments = {
        init: function () {
            selectDocuments.$form = $('#validate-select-documents');
            selectDocuments.$drivingLicenceDetails = $('#driving_licence_details');
            selectDocuments.$passportDetails = $('#passport_details');
            var errorMessageForPassportDate = selectDocuments.$passportDetails.data('msg');
            var errorMessage = selectDocuments.$form.data('msg');
            $.validator.addMethod('drivingLicenceDetailsValidation', function(value, element) {
                return $('#select_documents_form_any_driving_licence_false').is(':checked') ||
                    ($('#select_documents_form_any_driving_licence_true').is(':checked')
                    && ($('#select_documents_form_driving_licence_great_britain').is(':checked')
                    || $('#select_documents_form_driving_licence_northern_ireland').is(':checked')))
            }, $.validator.format(selectDocuments.$form.data('msg')));

            selectDocuments.validator = selectDocuments.$form.validate($.extend({}, GOVUK.validation.radiosValidation, {
                rules: {
                    'select_documents_form[any_driving_licence]': 'required',
                    'select_documents_form[passport]': 'required',
                    'select_documents_form[driving_licence]': 'drivingLicenceDetailsValidation',
                    'select_documents_form[passport_expiry][day]': 'required',
                    'select_documents_form[passport_expiry][month]': 'required',
                    'select_documents_form[passport_expiry][year]': 'required'
                },
                groups: {
                    primary: 'select_documents_form[any_driving_licence] select_documents_form[passport] select_documents_form[driving_licence]',
                    passport: 'select_documents_form[passport_expiry][day] select_documents_form[passport_expiry][month] select_documents_form[passport_expiry][year]'
                },
                messages: {
                    'select_documents_form[any_driving_licence]': errorMessage,
                    'select_documents_form[passport]': errorMessage,
                    'select_documents_form[driving_licence]': errorMessage,
                    'select_documents_form[passport_expiry][day]': errorMessageForPassportDate,
                    'select_documents_form[passport_expiry][month]': errorMessageForPassportDate,
                    'select_documents_form[passport_expiry][year]': errorMessageForPassportDate
                }
            }));

          selectDocuments.setPassportDetailsVisibility();
          selectDocuments.$form.find('input[name="select_documents_form[passport]"]')
            .on('click', selectDocuments.setPassportDetailsVisibility)

          selectDocuments.setDrivingLicenceDetailsVisibility();
            selectDocuments.$form.find('input[name="select_documents_form[any_driving_licence]"]')
                .on('click', selectDocuments.setDrivingLicenceDetailsVisibility)

            // Changing driving license validation to false when there are validation errors
            // on the driving license detail fields does not cause validation execution on the
            // erroneous fields. This causes the main error message to remain visible even though
            // there are no visible errors for the user.
            //
            // To work around this, we force the whole form validation on the above mentioned
            // scenario.
            selectDocuments.$form.find('#select_documents_form_any_driving_licence_false')
                .on('change', function () {
                    if (!GOVUK.selectDocumentsCleverQuestions.validator.valid()) {
                        // the name of the api-function to validate the form is form :/
                        // https://jqueryvalidation.org/Validator.form
                        selectDocuments.validator.form()
                    }
                })
        },
        setDrivingLicenceDetailsVisibility: function () {
            if (selectDocuments.hasAnyDrivingLicence()) {
                selectDocuments.$drivingLicenceDetails.removeClass('js-hidden');
            } else {
                selectDocuments.$drivingLicenceDetails.removeClass('form-group-error')
                    .find('.selected').removeClass('selected').find('input').prop('checked', false);
                selectDocuments.$drivingLicenceDetails.addClass('js-hidden');
            }
        },
        hasAnyDrivingLicence: function () {
            var input = $('input[name="select_documents_form[any_driving_licence]"]:checked');
            return input.length === 1 && input.val() === 'true';
        },
        setPassportDetailsVisibility: function () {
          if (selectDocuments.hasPassportExpiry()) {
            selectDocuments.$passportDetails.removeClass('js-hidden');
          } else {
            selectDocuments.removePassportExpiryErrorMessages();
            $( "[id^=select_documents_form_passport_expiry_][id$='-error']" ).parent().remove();
            selectDocuments.$passportDetails.removeClass('form-group-error')
              .find('.selected').removeClass('selected').find('input').prop('checked', false);
            selectDocuments.$passportDetails.addClass('js-hidden');
          }
        },
        hasPassportExpiry: function () {
          var input = $('input[name="select_documents_form[passport]"]:checked');
          return input.length === 1 && input.val() === 'yes_expired';
        },
        removePassportExpiryErrorMessages: function () {
          $('#passport-error').parent().remove();
        }
    };

    GOVUK.selectDocumentsCleverQuestions = selectDocuments;

    global.GOVUK = GOVUK;
})(window);
