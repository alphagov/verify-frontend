describe("Select Documents Form", function () {

    var formWithNoErrors = '<div id="no-documents-message" class="govuk-visually-hidden" aria-live="assertive"></div>' +
        '<div class="grid-row">' +
        '<div class="column-two-thirds">' +
        '<h1 class="govuk-heading-l">Your photo identity document</h1>' +
        '<p>Certified companies use information from identity documents to verify you.</p>' +
        '<div class="panel panel-border-narrow">' +
        'The more identity documents you can provide now, the more likely it is that the company can verify you successfully.' +
        '</div>' +
        '<form id="validate-select-documents" class="select-documents-form" novalidate="novalidate" data-msg="Please select the documents you have" action="/select-documents" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="authenticity_token" value="2Vb46CN8Bljm/f6lHNxqu3PGWMVAsVdjIe6uJrnzoxbUic0vi8jU/Ea8UrmOWBtwan860qN2uvdFNW8DoFNVuQ==" />' +
        '<div class="form-group">' +
        '<h2 class="govuk-heading-m">Do you have a valid UK photocard driving licence, full or provisional?</h2>' +
        '<div class="form-group form-field">' +
        '<fieldset>' +
        '<label class="block-label selection-button-radio" for="select_documents_form_any_driving_licence_true"><input type="radio" value="true" name="select_documents_form[any_driving_licence]" id="select_documents_form_any_driving_licence_true" /> Yes</label>' +
        '<label class="block-label selection-button-radio" for="select_documents_form_any_driving_licence_false"><input type="radio" value="false" name="select_documents_form[any_driving_licence]" id="select_documents_form_any_driving_licence_false" /> No</label>' +
        '</fieldset>' +
        '</div>' +
        '<div id="driving_licence_details" class="form-group panel panel-border-narrow">' +
        '<fieldset>' +
        '<legend><span class="form-label">Where was your driving licence issued?</span></legend>' +
        '<div class="multiple-choice"><input value="great_britain" name="select_documents_form[driving_licence]" id="select_documents_form_driving_licence_great_britain" type="radio"> <label for="select_documents_form_driving_licence_great_britain">Great Britain</label></div>' +
        '<div class="multiple-choice"><input value="northern_ireland" name="select_documents_form[driving_licence]" id="select_documents_form_driving_licence_northern_ireland" type="radio"> <label for="select_documents_form_driving_licence_northern_ireland">Northern Ireland</label></div>' +
        '</fieldset>' +
        '</div>' +
        '<h2 class="govuk-heading-m">Do you have a UK passport?</h2>' +
        '<div class="form-group form-field">' +
        '<fieldset>' +
        '<label class="block-label selection-button-radio" for="select_documents_form_passport_true"><input type="radio" value="true" name="select_documents_form[passport]" id="select_documents_form_passport_true" /> Yes</label>' +
        '<label class="block-label selection-button-radio" for="select_documents_form_passport_false"><input type="radio" value="false" name="select_documents_form[passport]" id="select_documents_form_passport_false" /> No</label>' +
        '</fieldset>' +
        '</div>' +
        '</div>' +
        '<div id="validation-error-message-js"></div>' +
        '<div class="actions">' +
        '<input type="submit" name="commit" value="Continue" class="button" id="next-button" />' +
        '<a href="/other-identity-documents">I don&#39;t have either of these documents</a>' +
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
        this.selectNoPassport = function () {
            answerQuestion('passport', false);
        };
        this.selectYesPassport = function () {
            answerQuestion('passport', true);
        };
        this.selectYesValidDrivingLicence = function () {
            answerQuestion('any_driving_licence', true);
        };
        this.selectNoValidDrivingLicence = function () {
            answerQuestion('any_driving_licence', false);
        };
        this.selectGBDrivingLicence = function () {
            answerQuestion('driving_licence', 'great_britain');
        };
    });

    afterEach(function () {
        $dom.remove();
    });

    it("should not initially show driving licence details section.", function () {
        expect(selectDocumentsForm.find('#driving_licence_details').attr("class")).toContain("js-hidden");
    });

    it("should show driving licence details section when user indicates valid driving licence", function () {
        this.selectYesValidDrivingLicence();
        expect(selectDocumentsForm.find('#driving_licence_details').attr("class")).not.toContain("js-hidden");
    });

    it("should not show driving licence details section when user indicates no valid driving licence", function () {
        this.selectNoValidDrivingLicence();
        expect(selectDocumentsForm.find('#driving_licence_details').attr("class")).toContain("js-hidden");
    });

    it("should have no errors on initialising the form.", function () {
        expect(selectDocumentsForm.find('.error').length).toBe(0);
    });

    it("should have errors on submit when no selections made.", function () {
        submitForm();
        expectErrorMessage('Please select the documents you have');
    });

    it("should have errors on submit when no driving licence selection made.", function () {
        this.selectNoPassport();
        submitForm();
        expectErrorMessage('Please select the documents you have');
    });

    it("should have errors on submit when no passport selection made.", function () {
        this.selectNoValidDrivingLicence();
        submitForm();
        expectErrorMessage('Please select the documents you have');
    });

    it("should clear errors when driving licence and passport details selected", function () {
        submitForm();
        expectErrorMessage('Please select the documents you have');
        this.selectYesValidDrivingLicence();
        this.selectYesPassport();
        expectNoError();
    });

    it("should have error when neither GB or NI details are not given for driving licence", function () {
        this.selectYesValidDrivingLicence();
        submitForm();
        expectErrorMessage('Please select the documents you have');
    });

    it("should not ask for driving licence details when no driving licence is selected", function () {
        this.selectNoValidDrivingLicence();
        submitForm();
        expectErrorMessage('Please select the documents you have');
    });

    it("should clear errors when driving licence details are given", function () {
        this.selectYesValidDrivingLicence();
        this.selectYesPassport();
        submitForm();
        expectErrorMessage('Please select the documents you have');
        this.selectGBDrivingLicence();
        expectNoError();
    });
});
