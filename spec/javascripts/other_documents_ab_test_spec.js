describe("Other Documents Form", function () {

    var formWithNoErrors = '<form id="validate-other-documents" class="select-documents-form" novalidate="novalidate" data-msg="Please select the documents you have" action="/other-identity-documents" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="authenticity_token" value="T6zqiRd91OTqJPwmIrde9NLSCNFRBr6035OKUNN3FYlKF7X9MR6pNRzStHVDEgm77ToTyq1ZKwXnAYG3st0Ejg==" />' +
                           '<div class="form-group">' +
                           '<h2 class="heading-medium">Do you have a non-UK passport, ID card and driving licence?</h2>' +
                           '<div class="form-group form-field">' +
                           '<fieldset>' +
                           '<label class="block-label selection-button-radio" for="other_identity_documents_form_non_uk_id_document_true"><input type="radio" value="true" name="other_identity_documents_form[non_uk_id_document]" id="other_identity_documents_form_non_uk_id_document_true" /> Yes</label>' +
                           '<label class="block-label selection-button-radio" for="other_identity_documents_form_non_uk_id_document_false"><input type="radio" value="false" name="other_identity_documents_form[non_uk_id_document]" id="other_identity_documents_form_non_uk_id_document_false" /> No</label>' +
                           '</fieldset>' +
                           '</div>' +
                           '</div>' +
                           '<div id="validation-error-message-js"></div>' +
                           '<div class="actions">' +
                           '<input type="submit" name="commit" value="Continue" class="button" id="next-button" />' +
                           '</div>' +
                           '</form>';

    var otherDocumentsForm;
    var $dom;

    function answerQuestion(document, answer) {
        otherDocumentsForm.find('input[name="other_identity_documents_form[' + document + ']"][value=' + answer + ']')
            .prop('checked', true)
            .trigger('click');
    }

    function submitForm() {
        otherDocumentsForm.triggerHandler('submit')
    }

    function expectErrorMessage(error) {
        expect(otherDocumentsForm.children('.form-group:first').is('.error')).toBe(true);
        expect(otherDocumentsForm.find('#validation-error-message-js').text()).toBe(error);
    }

    function expectNoError() {
        expect(otherDocumentsForm.children('.form-group:first').is('.error')).toBe(false);
        expect(otherDocumentsForm.find('#validation-error-message-js').text()).toBe('');
    }

    beforeEach(function () {
        $dom = $('<div>' + formWithNoErrors + '</div>');
        $(document.body).append($dom);
        GOVUK.validation.init();
        GOVUK.otherDocuments.init();
        otherDocumentsForm = GOVUK.otherDocuments.$form;
        this.selectYesNonUKDoc = function () {
            answerQuestion('non_uk_id_document', true);
        };
        this.selectNoValidDrivingLicence = function () {
            answerQuestion('non_uk_id_document', false);
        };
    });

    afterEach(function () {
        $dom.remove();
    });

    it("should have no errors on initialising the form.", function () {
        expect(otherDocumentsForm.find('.error').length).toBe(0);
    });

    it("should have errors on submit when no selections made.", function () {
        submitForm();
        expectErrorMessage('Please select the documents you have');
    });

    it("should clear errors when non UK id document details selected", function () {
        submitForm();
        expectErrorMessage('Please select the documents you have');

        this.selectYesNonUKDoc()

        expectNoError();
    });

    it("should clear errors when no valid driving licence selected", function () {
        submitForm();
        expectErrorMessage('Please select the documents you have');

        this.selectNoValidDrivingLicence()

        expectNoError();
    });

});
