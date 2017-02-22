(function (global) {
    "use strict";
    var GOVUK = global.GOVUK || {};
    var $ = global.jQuery;

    var otherDocuments = {
        init: function () {
            otherDocuments.$form = $('#validate-other-documents');
            if (otherDocuments.$form.length === 1) {
                $.validator.addMethod('otherDocumentsValidation', function(value, element) {
                    var checkedElements = otherDocuments.$form.find('input[type=radio]').filter(':checked');
                    var hasAtLeastOneDocument = checkedElements.filter('[value=true]').length > 0;
                    return hasAtLeastOneDocument;
                }, $.validator.format(otherDocuments.$form.data('msg')));

                otherDocuments.validator = otherDocuments.$form.validate($.extend({}, GOVUK.validation.radiosValidation, {
                    rules: {
                        'other_identity_documents_form[non_uk_id_document]': 'otherDocumentsValidation'
                    },
                    groups: {
                        non_uk_id_document: 'other_identity_documents_form[non_uk_id_document]'
                    },
                    highlight: function(element, errorClass) {
                        otherDocuments.$form.children('.form-group:first').addClass('error');
                    },
                    unhighlight: function(element, errorClass) {
                        otherDocuments.$form.children('.form-group:first').removeClass('error');
                    }
                }));

            }
        }
    };

    GOVUK.otherDocuments = otherDocuments;

    global.GOVUK = GOVUK;
})(window);
