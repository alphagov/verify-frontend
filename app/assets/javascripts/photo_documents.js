(function (global) {
    "use strict";
    var GOVUK = global.GOVUK || {};
    var $ = global.jQuery;

    var photoDocuments = {
        init: function () {
            photoDocuments.$form = $('#validate-photo-documents');
            photoDocuments.$drivingLicenceDetails = $('#driving_licence_details');
            var errorMessage = photoDocuments.$form.data('msg');
            $.validator.addMethod('drivingLicenceDetailsValidation', function(value, element) {
                return $('#photo_documents_form_any_driving_licence_false').is(':checked') ||
                    ($('#photo_documents_form_any_driving_licence_true').is(':checked') && ($('#photo_documents_form_driving_licence').is(':checked') || $('#photo_documents_form_ni_driving_licence').is(':checked')))
            }, $.validator.format(photoDocuments.$form.data('msg')));

            photoDocuments.validator = photoDocuments.$form.validate($.extend({}, GOVUK.validation.radiosValidation, {
                rules: {
                    'photo_documents_form[any_driving_licence]': 'required',
                    'photo_documents_form[passport]': 'required',
                    'photo_documents_form[driving_licence]': 'drivingLicenceDetailsValidation',
                    'photo_documents_form[ni_driving_licence]': 'drivingLicenceDetailsValidation',
                },
                groups: {
                    primary: 'photo_documents_form[any_driving_licence] photo_documents_form[passport] photo_documents_form[driving_licence] photo_documents_form[ni_driving_licence]'
                },
                messages: {
                    'photo_documents_form[any_driving_licence]': errorMessage,
                    'photo_documents_form[passport]': errorMessage,
                    'photo_documents_form[driving_licence]': errorMessage,
                    'photo_documents_form[ni_driving_licence]': errorMessage
                }
            }));

            photoDocuments.setDrivingLicenceDetailsVisibility();
            photoDocuments.$form.find('input[name="photo_documents_form[any_driving_licence]"]')
                .on('click', photoDocuments.setDrivingLicenceDetailsVisibility)

            // Changing driving license validation to false when there are validation errors
            // on the driving license detail fields does not cause validation execution on the
            // erroneous fields. This causes the main error message to remain visible even though
            // there are no visible errors for the user.
            //
            // To work around this, we force the whole form validation on the above mentioned
            // scenario.
            photoDocuments.$form.find('#photo_documents_form_any_driving_licence_false')
                .on('change', function () {
                    if (!GOVUK.photoDocuments.validator.valid()) {
                        // the name of the api-function to validate the form is form :/
                        // https://jqueryvalidation.org/Validator.form
                        photoDocuments.validator.form()
                    }
                })

        },

        setDrivingLicenceDetailsVisibility: function () {
            if (photoDocuments.hasAnyDrivingLicence()) {
                photoDocuments.$drivingLicenceDetails.removeClass('js-hidden');
            } else {
                photoDocuments.$drivingLicenceDetails.removeClass('form-group-error')
                    .find('.selected').removeClass('selected').find('input').prop('checked', false);
                photoDocuments.$drivingLicenceDetails.addClass('js-hidden');
            }
        },
        hasAnyDrivingLicence: function () {
            var input = $('input[name="photo_documents_form[any_driving_licence]"]:checked');
            return input.length === 1 && input.val() === 'true';
        }
    };

    GOVUK.photoDocuments = photoDocuments;

    global.GOVUK = GOVUK;
})(window);
