//= require jquery
//= require jquery.validate
//= require validation
//= require select_documents

describe("Select Documents Form", function () {

    var formWithNoErrors = '<form id="validate-documents" action="/select-documents" method="POST">' +
                             '<div class="form-group ">' +
                               '<fieldset>' +
                                 '<legend>Do you have these documents with you?</legend>' +
                                 '<div class="form-group ">' +
                                   '<fieldset class="inline"><span>1. UK photocard driving licence (excluding Northern Ireland)</span>' +
                                     '<label class="block-label" for="driving_licence_yes" onclick="">' +
                                       '<input id="driving_licence_yes" name="driving_licence" value="true" type="radio"><span><span class="inner"></span></span>Yes</label>' +
                                     '<label class="block-label" for="driving_licence_no" onclick="">' +
                                       '<input id="driving_licence_no" name="driving_licence" value="false" type="radio"><span><span class="inner"></span></span>No</label>' +
                                   '</fieldset>' +
                                 '</div>' +
                                 '<div class="form-group ">' +
                                   '<fieldset class="inline"><span>2. UK passport</span>' +
                                     '<label class="block-label" for="passport_yes" onclick="">' +
                                       '<input id="passport_yes" name="passport" value="true" type="radio"><span><span class="inner"></span></span>Yes</label>' +
                                     '<label class="block-label" for="passport_no" onclick="">' +
                                       '<input id="passport_no" name="passport" value="false" type="radio"><span><span class="inner"></span></span>No</label>' +
                                   '</fieldset>' +
                                 '</div>' +'' +
                                 '<div class="form-group ">' +
                                   '<fieldset class="inline"><span>3. Passport from another country</span>' +
                                     '<label class="block-label" for="other_passport_yes" onclick="">' +
                                       '<input id="other_passport_yes" name="other_passport" value="true" type="radio"><span><span class="inner"></span></span>Yes</label>' +
                                     '<label class="block-label" for="other_passport_no" onclick="">' +
                                       '<input id="other_passport_no" name="other_passport" value="false" type="radio"><span><span class="inner"></span></span>No</label>' +
                                   '</fieldset>' +
                                 '</div>' +
                                 '<label class="block-label" for="no-documents" onclick="">' +
                                   '<input id="no-documents" name="rails_no_documents" class="js-no-docs" value="true" type="checkbox"><span><span class="inner"></span></span>I don’t have any of these documents with me</label>' +
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

    beforeEach(function () {
        $dom = $('<div>'+formWithNoErrors+'</div>');
        $(document.body).append($dom);
        GOVUK.validation.init();
        GOVUK.selectDocuments.init();
        selectDocumentsForm = GOVUK.selectDocuments.$form;
    });

    afterEach(function() {
        $dom.remove();
    });

    it("should have no errors on initialising the form.", function () {
        expect(selectDocumentsForm.find('.error').length).toBe(0);
    });

    it("should have errors on submit when no selections made.", function () {
        selectDocumentsForm.triggerHandler('submit');
        expect(selectDocumentsForm.children('.form-group:first').is('.error')).toBe(true);
        expect(selectDocumentsForm.find('#validation-error-message-js').text()).toBe('Please select the documents you have');
    });

    it("should clear errors when at least one selection that implies evidence is made after failed validation.", function () {
        // Given
        selectDocumentsForm.triggerHandler('submit');
        expect(selectDocumentsForm.children('.form-group:first').is('.error')).toBe(true);
        // When - HACK one time click doesn’t work in the test ...
        selectDocumentsForm.find('input[name=passport][value=true]').trigger('click');
        selectDocumentsForm.find('input[name=passport][value=true]').trigger('click');
        // Then
        expect(selectDocumentsForm.children('.form-group:first').is('.error')).toBe(false);
        expect(selectDocumentsForm.find('#validation-error-message-js').text()).toBe('');
    });

    it("should have errors when the only selection that implies no evidence is made.", function () {
        selectDocumentsForm.find('input[name=passport][value=false]').trigger('click');
        selectDocumentsForm.triggerHandler('submit');
        expect(selectDocumentsForm.children('.form-group:first').is('.error')).toBe(true);
        expect(selectDocumentsForm.find('#validation-error-message-js').text()).toBe('Please select the documents you have');
    });

    it("should have no error on submit when other passport is true and passport is false", function () {
        selectDocumentsForm.find('input[name=other_passport][value=true]').trigger('click');
        selectDocumentsForm.find('input[name=passport][value=false]').trigger('click');
        selectDocumentsForm.triggerHandler('submit');
        expect(selectDocumentsForm.children('.form-group:first').is('.error')).toBe(false);
        expect(selectDocumentsForm.find('#validation-error-message-js').text()).toBe('');
    });

    it("should have no errors on submit when selections that imply evidence are made - Happy Path", function () {
        selectDocumentsForm.find('input[name=passport][value=true]').trigger('click');
        selectDocumentsForm.triggerHandler('submit');
        expect(selectDocumentsForm.children('.form-group:first').is('.error')).toBe(false);
        expect(selectDocumentsForm.find('#validation-error-message-js').text()).toBe('');
    });
});
