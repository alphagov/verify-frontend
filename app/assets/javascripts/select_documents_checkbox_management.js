(function (global) {
    "use strict";
    var GOVUK = global.GOVUK || {};
    var $ = global.jQuery;

    var selectDocumentsVariantC = {

        init: function() {
            $("#select_documents_variant_c_form_has_nothing").click(this.unsetAllButNothing);

            $("#select_documents_variant_c_form_has_valid_passport").click(this.unsetNothing);
            $("#select_documents_variant_c_form_has_driving_license").click(this.unsetNothing);
            $("#select_documents_variant_c_form_has_phone_can_app").click(this.unsetNothing);
            $("#select_documents_variant_c_form_has_credit_card").click(this.unsetNothing);
        },

        unsetNothing: function() {
            $("#select_documents_variant_c_form_has_nothing").prop("checked", false);
        },

        unsetAllButNothing: function() {
            $("#select_documents_variant_c_form_has_valid_passport").prop("checked", false);
            $("#select_documents_variant_c_form_has_driving_license").prop("checked", false);
            $("#select_documents_variant_c_form_has_phone_can_app").prop("checked", false);
            $("#select_documents_variant_c_form_has_credit_card").prop("checked", false);
        }
    };

    GOVUK.selectDocumentsVariantC = selectDocumentsVariantC;

    global.GOVUK = GOVUK;
}(window));
