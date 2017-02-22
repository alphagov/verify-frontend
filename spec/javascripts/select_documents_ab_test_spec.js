describe("Photo Documents Form", function () {

    var formWithNoErrors = '<div id="no-documents-message" class="visually-hidden" aria-live="assertive"></div>' +
        '<div class="grid-row">' +
        '<div class="column-two-thirds">' +
        '<h1 class="heading-large">Your photo identity document</h1>' +
        '<p>Certified companies use information from identity documents to verify you.</p>' +
        '<div class="panel panel-border-narrow">' +
        'The more identity documents you can provide now, the more likely it is that the company can verify you successfully.' +
        '</div>' +
        '<form id="validate-photo-documents" class="select-documents-form" novalidate="novalidate" data-msg="Please select the documents you have" action="/select-documents" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="authenticity_token" value="2Vb46CN8Bljm/f6lHNxqu3PGWMVAsVdjIe6uJrnzoxbUic0vi8jU/Ea8UrmOWBtwan860qN2uvdFNW8DoFNVuQ==" />' +
        '<div class="form-group">' +
        '<h2 class="heading-medium">Do you have a valid UK photocard driving licence, full or provisional?</h2>' +
        '<div class="form-group form-field">' +
        '<fieldset>' +
        '<label class="block-label selection-button-radio" for="photo_documents_form_any_driving_licence_true"><input type="radio" value="true" name="photo_documents_form[any_driving_licence]" id="photo_documents_form_any_driving_licence_true" /> Yes</label>' +
        '<label class="block-label selection-button-radio" for="photo_documents_form_any_driving_licence_false"><input type="radio" value="false" name="photo_documents_form[any_driving_licence]" id="photo_documents_form_any_driving_licence_false" /> No</label>' +
        '</fieldset>' +
        '</div>' +
        '<div id="driving_licence_details" class="form-group panel panel-border-narrow js-hidden">' +
        '<fieldset>' +
        '<legend><span class="form-label">Where was your driving licence issued?</span></legend>' +
        '<label class="block-label selection-button-checkbox" for="driving_licence">' +
        '<input name="photo_documents_form[driving_licence]" type="hidden" value="0" /><input type="checkbox" value="1" name="photo_documents_form[driving_licence]" id="photo_documents_form_driving_licence" />Great Britain' +
        '</label>' +
        '<label class="block-label selection-button-checkbox" for="ni_driving_licence">' +
        '<input name="photo_documents_form[ni_driving_licence]" type="hidden" value="0" /><input type="checkbox" value="1" name="photo_documents_form[ni_driving_licence]" id="photo_documents_form_ni_driving_licence" />Northern Ireland' +
        '</label>' +
        '</fieldset>' +
        '</div>' +
        '<h2 class="heading-medium">Do you have a UK passport?</h2>' +
        '<div class="form-group form-field">' +
        '<fieldset>' +
        '<label class="block-label selection-button-radio" for="photo_documents_form_passport_true"><input type="radio" value="true" name="photo_documents_form[passport]" id="photo_documents_form_passport_true" /> Yes</label>' +
        '<label class="block-label selection-button-radio" for="photo_documents_form_passport_false"><input type="radio" value="false" name="photo_documents_form[passport]" id="photo_documents_form_passport_false" /> No</label>' +
        '</fieldset>' +
        '</div>' +
        '</div>' +
        '<div id="validation-error-message-js"></div>' +
        '<div class="actions">' +
        '<input type="submit" name="commit" value="Continue" class="button" id="next-button" />' +
        '<a href="/other-identity-documents">I don&#39;t have either of these documents</a>' +
        '</div>' +
        '</form>';


    var photoDocumentsForm;
    var $dom;

    function answerQuestion(document, answer) {
        photoDocumentsForm.find('input[name="photo_documents_form[' + document + ']"][value=' + answer + ']')
            .prop('checked', true)
            .trigger('click');
    }
    
    function submitForm() {
        photoDocumentsForm.triggerHandler('submit')
    }

    function expectErrorMessage(error) {
        expect(photoDocumentsForm.find('#validation-error-message-js').text()).toBe(error);
    }

    function expectNoError() {
        expect(photoDocumentsForm.children('.form-group:first').is('.error')).toBe(false);
        expect(photoDocumentsForm.find('#validation-error-message-js').text()).toBe('');
    }

    beforeEach(function () {
        $dom = $('<div>' + formWithNoErrors + '</div>');
        $(document.body).append($dom);
        GOVUK.validation.init();
        GOVUK.photoDocuments.init();
        photoDocumentsForm = GOVUK.photoDocuments.$form;
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
            photoDocumentsForm.find('input[name="photo_documents_form[driving_licence]"]').trigger('click');
        };
    });

    afterEach(function () {
        $dom.remove();
    });

    it("should not initially show driving licence details section.", function () {
        expect(photoDocumentsForm.find('#driving_licence_details').attr("class")).toContain("js-hidden");
    });

    it("should show driving licence details section when user indicates valid driving licence", function () {
        this.selectYesValidDrivingLicence();
        expect(photoDocumentsForm.find('#driving_licence_details').attr("class")).not.toContain("js-hidden");
    });

    it("should not show driving licence details section when user indicates no valid driving licence", function () {
        this.selectNoValidDrivingLicence();
        expect(photoDocumentsForm.find('#driving_licence_details').attr("class")).toContain("js-hidden");
    });

    it("should have no errors on initialising the form.", function () {
        expect(photoDocumentsForm.find('.error').length).toBe(0);
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
