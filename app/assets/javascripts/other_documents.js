(function (global) {
    "use strict";
    var GOVUK = global.GOVUK || {};
    var $ = global.jQuery;

    var otherDocuments = {
        init: function () {
            otherDocuments.$form = $('#validate-other-documents');
            var errorMessage = otherDocuments.$form.data('msg');
            otherDocuments.validator = otherDocuments.$form.validate($.extend({}, GOVUK.validation.radiosValidation, {
                rules: {
                    'other_identity_documents_form[non_uk_id_document]': 'required'
                },
                groups: {
                    non_uk_id_document: 'other_identity_documents_form[non_uk_id_document]'
                },
                messages: {
                    'other_identity_documents_form[non_uk_id_document]': errorMessage
                },

                highlight: function(element, errorClass) {
                    otherDocuments.$form.children('.form-group:first').addClass('error');
                },
                unhighlight: function(element, errorClass) {
                    otherDocuments.$form.children('.form-group:first').removeClass('error');
                }
            }));
        }
    };

    GOVUK.otherDocuments = otherDocuments;

    global.GOVUK = GOVUK;
})(window);
