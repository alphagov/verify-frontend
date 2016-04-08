//= require jquery
//= require jquery.validate
//= require validation
//= require select_documents

describe("Select Documents Form", function () {

    var formWithNoErrors = '<form id="validate-documents" action="/select-documents" method="POST" data-msg="Please select the documents you have">' +
                             '<div class="form-group ">' +
                               '<fieldset>' +
                                 '<legend>Do you have these documents with you?</legend>' +
                                 '<div class="form-group ">' +
                                   '<fieldset class="inline"><span>1. UK photocard driving licence (excluding Northern Ireland)</span>' +
                                     '<label class="block-label" for="driving_licence_yes" onclick="">' +
                                       '<input id="driving_licence_yes" name="select_documents_form[driving_licence]" value="true" type="radio"><span><span class="inner"></span></span>Yes</label>' +
                                     '<label class="block-label" for="driving_licence_no" onclick="">' +
                                       '<input id="driving_licence_no" name="select_documents_form[driving_licence]" value="false" type="radio"><span><span class="inner"></span></span>No</label>' +
                                   '</fieldset>' +
                                 '</div>' +
                                 '<div class="form-group ">' +
                                   '<fieldset class="inline"><span>2. UK passport</span>' +
                                     '<label class="block-label" for="passport_yes" onclick="">' +
                                       '<input id="passport_yes" name="select_documents_form[passport]" value="true" type="radio"><span><span class="inner"></span></span>Yes</label>' +
                                     '<label class="block-label" for="passport_no" onclick="">' +
                                       '<input id="passport_no" name="select_documents_form[passport]" value="false" type="radio"><span><span class="inner"></span></span>No</label>' +
                                   '</fieldset>' +
                                 '</div>' +'' +
                                 '<div class="form-group ">' +
                                   '<fieldset class="inline"><span>3. Passport from another country</span>' +
                                     '<label class="block-label" for="other_passport_yes" onclick="">' +
                                       '<input id="other_passport_yes" name="select_documents_form[non_uk_id_document]" value="true" type="radio"><span><span class="inner"></span></span>Yes</label>' +
                                     '<label class="block-label" for="other_passport_no" onclick="">' +
                                       '<input id="other_passport_no" name="select_documents_form[non_uk_id_document]" value="false" type="radio"><span><span class="inner"></span></span>No</label>' +
                                   '</fieldset>' +
                                 '</div>' +
                                 '<label class="block-label" for="no-documents" onclick="">' +
                                   '<input id="no-documents" name="select_documents_form[no_documents]" class="js-no-docs" value="true" type="checkbox"><span><span class="inner"></span></span>I don’t have any of these documents with me</label>' +
                               '</fieldset>' +
                             '</div>' +
                             '<div id="validation-error-message-js"></div>' +
                             '<p class="valid-note"><strong>Please note:&nbsp;</strong>you cannot use documents that are out of date.</p>' +
                             '<div class="form-group">' +
                               '<input class="button" id="next-button" value="Continue" type="submit">' +
                             '</div>' +
                           '</form>';


    var selectDocumentsForm;
    var $dom;

    function answerQuestion(document, answer) {
        selectDocumentsForm.find('input[name="select_documents_form[' + document + ']"][value=' + answer + ']')
            .prop('checked', true)
            .trigger('click');
    }

    function submitForm() {
        selectDocumentsForm.triggerHandler('submit')
    }

    function expectErrorMessage(error) {
        expect(selectDocumentsForm.children('.form-group:first').is('.error')).toBe(true);
        expect(selectDocumentsForm.find('#validation-error-message-js').text()).toBe(error);
    }

    function expectNoError() {
        expect(selectDocumentsForm.children('.form-group:first').is('.error')).toBe(false);
        expect(selectDocumentsForm.find('#validation-error-message-js').text()).toBe('');
    }

    beforeEach(function () {
        $dom = $('<div>' + formWithNoErrors + '</div>');
        $(document.body).append($dom);
        GOVUK.validation.init();
        GOVUK.selectDocuments.init();
        selectDocumentsForm = GOVUK.selectDocuments.$form;
        this.noDocumentsCheckbox = selectDocumentsForm.find('input[name="select_documents_form[no_documents]"][value=true]');
        this.selectNoPassport = function () {
            answerQuestion('passport', false);
        };
        this.selectYesPassport = function () {
            answerQuestion('passport', true);
        };
        this.selectNoDrivingLicence = function () {
            answerQuestion('driving_licence', false);
        };
        this.selectNoNonUKIdDocument = function () {
            answerQuestion('non_uk_id_document', false);
        };
        this.selectYesNonUKIdDocument = function () {
            answerQuestion('non_uk_id_document', true);
        };
    });

    afterEach(function () {
        $dom.remove();
    });

    it("should have no errors on initialising the form.", function () {
        expect(selectDocumentsForm.find('.error').length).toBe(0);
    });

    it("should have errors on submit when no selections made.", function () {
        submitForm();
        expectErrorMessage('Please select the documents you have');
    });

    it("should clear errors when at least one selection that implies evidence is made after failed validation.", function () {
        submitForm();
        expectErrorMessage('Please select the documents you have');

        this.selectYesPassport();

        expectNoError();
    });

    it("should have errors when the only selection that implies no evidence is made.", function () {
        this.selectNoPassport();
        submitForm();
        expectErrorMessage('Please select the documents you have');
    });

    it("should have errors when only 2 selections are made and both imply no evidence.", function () {
        this.selectNoPassport();
        this.selectNoDrivingLicence();
        submitForm();
        expectErrorMessage('Please select the documents you have');
    });

    it("should have no error on submit when other passport is true and passport is false", function () {
        this.selectYesNonUKIdDocument();
        this.selectNoPassport();
        submitForm();
        expectNoError();
    });

    it("should have no errors on submit when selections that imply evidence are made - Happy Path", function () {
        this.selectYesPassport();
        submitForm();
        expectNoError();
    });

    it("should have no errors on submit when all selections imply no evidence", function () {
        this.selectNoPassport();
        this.selectNoDrivingLicence();
        this.selectNoNonUKIdDocument();
        submitForm();
        expect(selectDocumentsForm.children('.form-group:first').is('.error')).toBe(false);
        expect(selectDocumentsForm.find('#validation-error-message-js').text()).toBe('');
    });

    it("should have no errors on submit when no documents selected", function () {
        this.noDocumentsCheckbox.trigger('click');
        submitForm();
        expect(selectDocumentsForm.children('.form-group:first').is('.error')).toBe(false);
        expect(selectDocumentsForm.find('#validation-error-message-js').text()).toBe('');
    });

    it("should select No for all document questions when no documents checkbox is checked", function () {
        this.noDocumentsCheckbox.trigger('click');
        expect(selectDocumentsForm.find('input[type=radio][value=false]:checked').length).toBe(3);
    });

    it("should uncheck the no documents checkbox when a Yes answer is selected", function () {
        this.noDocumentsCheckbox.trigger('click');
        this.selectYesPassport();
        expect(this.noDocumentsCheckbox.is(':checked')).toBe(false);
    });
});
