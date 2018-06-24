(function (global) {
    "use strict";
    var GOVUK = global.GOVUK || {};
    var $ = global.jQuery;

    var otherDocuments = {
        toggleSecondaryQuestion: function() {
            var otherDocumentsState = $('input[name="other_identity_documents_variant_form[non_uk_id_document]"]:checked').val();

            if (otherDocumentsState === undefined) {
                           otherDocuments.$smartphoneQuestion
                               .addClass('js-hidden', true)
                               .find('input').prop('checked',false);
                       } else if (otherDocumentsState === 'true') {
                           otherDocuments.$smartphoneQuestion.removeClass('js-hidden');
                       } else if (otherDocumentsState === 'false') {
                           otherDocuments.$smartphoneQuestion.addClass('js-hidden').removeClass('form-group-error')
                               .find('input').prop('checked',false);
                       }
                        otherDocuments.$form.find('.form-group').removeClass('form-group-error');
                        otherDocuments.validator.resetForm();
                    },

            init: function () {
                        otherDocuments.$form = $('#validate-other-documents');
                        otherDocuments.$smartphoneQuestion = $('#smartphone-question');
                        var errorMessage = otherDocuments.$form.data('msg');
                        otherDocuments.validator = otherDocuments.$form.validate($.extend({}, GOVUK.validation.radiosValidation, {
                                rules: {
                                    'other_identity_documents_variant_form[non_uk_id_document]': 'required',
                                        'other_identity_documents_variant_form[smart_phone]': 'required'
                                },
                            groups: {
                                    non_uk_id_document: 'other_identity_documents_variant_form[non_uk_id_document]'
                                },
                            messages: {
                                    'other_identity_documents_variant_form[non_uk_id_document]': errorMessage,
                                        'other_identity_documents_variant_form[smart_phone]': errorMessage
                                }
                        }));
                        otherDocuments.$form.find('input[name="other_identity_documents_variant_form[non_uk_id_document]"]').on('click',otherDocuments.toggleSecondaryQuestion);
                        otherDocuments.toggleSecondaryQuestion();
        }
    };
    GOVUK.otherDocumentsVariant = otherDocuments;

    global.GOVUK = GOVUK;
})(window);
