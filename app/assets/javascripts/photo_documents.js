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
            photoDocuments.$form.find('input[name="photo_documents_form[any_driving_licence]"]').on('click', photoDocuments.setDrivingLicenceDetailsVisibility);
        },

        setDrivingLicenceDetailsVisibility: function () {
            if (photoDocuments.hasAnyDrivingLicence()) {
                photoDocuments.$drivingLicenceDetails.removeClass('js-hidden');
            } else {
                photoDocuments.$drivingLicenceDetails.removeClass('error')
                    .find('.selected').removeClass('selected').find('input').prop('checked', false);
                photoDocuments.$drivingLicenceDetails.find('input').trigger('click');
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
