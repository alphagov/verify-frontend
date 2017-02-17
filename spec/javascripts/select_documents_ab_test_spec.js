describe("Select Documents Form", function () {

    var formWithNoErrors = '';


    var selectDocumentsForm;
    var $dom;

    function answerQuestion(document, answer) {
        selectDocumentsForm.find('input[name="select_documents_form[' + document + ']"][value=' + answer + ']')
            .prop('checked', true)
            .trigger('click');
    }

    function fillInPassportExpiryDate(day, month, year) {
        selectDocumentsForm.find('#passport-expiry-day').val(day);
        selectDocumentsForm.find('#passport-expiry-month').val(month);
        selectDocumentsForm.find('#passport-expiry-year').val(year);
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
        this.selectExpiredPassport = function () {
            answerQuestion('expired_passport', true);
        };
        this.selectYesValidDrivingLicence = function () {
            answerQuestion('valid_driving_licence', true);
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

    it("should clear errors when driving licence or passport details selected", function () {
        submitForm();
        expectErrorMessage('Please select the documents you have');
        this.selectYesPassport();

        expectNoError();
    });

    it("should have error when neither GB or NI details are not given for driving licence", function () {
        this.selectYesValidDrivingLicence()
        submitForm();
        expectErrorMessage('Please select the driving licence you have');
    });

    it("should have errors when passport expiration details is not a valid date ", function () {
        this.selectExpiredPassport();
        this.fillInPassportExpiryDate(31, 11, 2016);
        submitForm();
        expectErrorMessage('Please enter a valid date');
    });

});
