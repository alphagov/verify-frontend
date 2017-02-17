describe("Other Documents Form", function () {

    var formWithNoErrors = '';


    var otherDocumentsForm;
    var $dom;

    function answerQuestion(document, answer) {
        otherDocumentsForm.find('input[name="select_documents_form[' + document + ']"][value=' + answer + ']')
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
        GOVUK.selectDocuments.init();
        otherDocumentsForm = GOVUK.selectDocuments.$form;
        this.noDocumentsCheckbox = otherDocumentsForm.find('input[name="select_documents_form[no_documents]"][value=true]');
        this.selectYesNonUKDoc = function () {
            answerQuestion('non_uk_id_document', true);
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

});
