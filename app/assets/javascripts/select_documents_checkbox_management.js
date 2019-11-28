(function (global) {
    "use strict";
    var GOVUK = global.GOVUK || {};
    var $ = global.jQuery;

    var selectDocumentsVariantC = {

        init: function () {
            $('#select_documents_variant_c_form_has_nothing').click(this.unset_all_but_nothing);

            $('#select_documents_variant_c_form_has_valid_passport').click(this.unset_nothing);
            $('#select_documents_variant_c_form_has_driving_license').click(this.unset_nothing);
            $('#select_documents_variant_c_form_has_phone_can_app').click(this.unset_nothing);
            $('#select_documents_variant_c_form_has_credit_card').click(this.unset_nothing);
        },

        unset_nothing: function () {
            $('#select_documents_variant_c_form_has_nothing').prop('checked', false);
        },

        unset_all_but_nothing: function () {
            $('#select_documents_variant_c_form_has_valid_passport').prop('checked', false);
            $('#select_documents_variant_c_form_has_driving_license').prop('checked', false);
            $('#select_documents_variant_c_form_has_phone_can_app').prop('checked', false);
            $('#select_documents_variant_c_form_has_credit_card').prop('checked', false);
        }
    };

    GOVUK.selectDocumentsVariantC = selectDocumentsVariantC;

    global.GOVUK = GOVUK;
})(window);
