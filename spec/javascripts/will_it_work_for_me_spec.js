describe("Will it work for me form", function () {
    var formWithNoErrors = '<form id="validate-will-it-work-for-me" class="will-it-work-for-me-form heading-banner-top-margin" novalidate="novalidate" data-msg="Please answer all the questions" action="/will-it-work-for-me" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="authenticity_token" value="vPUzc2UPWlp7kMZHVfMA6dv84Owy6LXL6Gmqs3AIWjSr5lTKrOFHqypv6HmlCBqqY0RcaDJ3U/GyHjijEzzkHw==" />' +
        '<div class="govuk-form-group" id="above-age-threshold">' +
        '<fieldset class="govuk-fieldset" aria-describedby="changed-name-hint">' +
        '<legend class="govuk-fieldset__legend govuk-fieldset__legend--m">' +
        '<h2 class="govuk-fieldset__heading">' +
        'Are you 20 or over?' +
        '</h2>' +
        '</legend>' +
        '<div class="govuk-radios">' +
        '<div class="govuk-radios__item">' +
        '<input class="govuk-radios__input" type="radio" value="true" name="will_it_work_for_me_form[above_age_threshold]" id="will_it_work_for_me_form_above_age_threshold_true" />' +
        '<label class="govuk-label govuk-radios__label" for="will_it_work_for_me_form_above_age_threshold_true">Yes</label>' +
        '</div>' +
        '<div class="govuk-radios__item">' +
        '<input class="govuk-radios__input" type="radio" value="false" name="will_it_work_for_me_form[above_age_threshold]" id="will_it_work_for_me_form_above_age_threshold_false" />' +
        '<label class="govuk-label govuk-radios__label" for="will_it_work_for_me_form_above_age_threshold_false">No</label>' +
        '</div>' +
        '</div>' +
        '</fieldset>' +
        '</div>' +
        '<div class="govuk-form-group" id="resident_last_12_months">' +
        '<fieldset class="govuk-fieldset" aria-describedby="how-contacted-conditional-hint">' +
        '<legend class="govuk-fieldset__legend govuk-fieldset__legend--m">' +
        '<h2 class="govuk-fieldset__heading">' +
        'Have you lived in the UK for the last 12 months?' +
        '</h2>' +
        '</legend>' +
        '<div class="govuk-radios govuk-radios--conditional" data-module="govuk-radios">' +
        '<div class="govuk-radios__item">' +
        '<input class="govuk-radios__input" type="radio" value="true" name="will_it_work_for_me_form[resident_last_12_months]" id="will_it_work_for_me_form_resident_last_12_months_true" />' +
        '<label class="govuk-label govuk-radios__label" for="will_it_work_for_me_form_resident_last_12_months_true">Yes</label>' +
        '</div>' +
        '<div class="govuk-radios__item">' +
        '<input class="govuk-radios__input" data-aria-controls="conditional-will_it_work_for_me_form_resident_last_12_months_false" type="radio" value="false" name="will_it_work_for_me_form[resident_last_12_months]" id="will_it_work_for_me_form_resident_last_12_months_false" />' +
        '<label class="govuk-label govuk-radios__label" for="will_it_work_for_me_form_resident_last_12_months_false">No</label>' +
        '</div>' +
        '<div class="govuk-radios__conditional govuk-radios__conditional--hidden"' +
        'id="conditional-will_it_work_for_me_form_resident_last_12_months_false">' +
        '<div class="govuk-form-group">' +
        '<fieldset class="govuk-fieldset">' +
        '<legend class="govuk-fieldset__legend govuk-fieldset__legend--m">' +
        '<h2 class="govuk-heading-s">' +
        'Which of these applies to you?' +
        '</h2>' +
        '</legend>' +
        '<div class="govuk-radios">' +
        '<div class="govuk-radios__item">' +
        '<input class="govuk-radios__input" type="radio" value="MovedRecently" name="will_it_work_for_me_form[not_resident_reason]" id="will_it_work_for_me_form_not_resident_reason_moved_recently" />' +
        '<label class="govuk-label govuk-radios__label" for="will_it_work_for_me_form_not_resident_reason_moved_recently">I moved to the UK in the last 12 months</label>' +
        '</div>' +
        '<div class="govuk-radios__item">' +
        '<input class="govuk-radios__input" type="radio" value="AddressButNotResident" name="will_it_work_for_me_form[not_resident_reason]" id="will_it_work_for_me_form_not_resident_reason_addressbutnotresident" />' +
        '<label class="govuk-label govuk-radios__label" for="will_it_work_for_me_form_not_resident_reason_address_but_not_resident">I have an address in the UK but I don’t live there</label>' +
        '</div>' +
        '<div class="govuk-radios__item">' +
        '<input class="govuk-radios__input" type="radio" value="NoAddress" name="will_it_work_for_me_form[not_resident_reason]" id="will_it_work_for_me_form_not_resident_reason_noaddress" />' +
        '<label class="govuk-label govuk-radios__label" for="will_it_work_for_me_form_not_resident_reason_no_address">I don’t have a UK address</label>' +
        '</div>' +
        '</div>' +
        '</fieldset>' +
        '</div>' +
        '</div>' +
        '</div>' +
        '</fieldset>' +
        '</div>       ' +
        '<div class="govuk-error-message" id="validation-error-message-js"></div>' +
        '<div class="actions">' +
        '<input type="submit" name="commit" value="Continue" class="govuk-button" id="next-button" />' +
        '</div>' +
        '</form>';

    var willItWorkForMeForm;
    var $dom;
    $('html').addClass('js-enabled');

    beforeEach(function () {
        $dom = $('<div>' + formWithNoErrors + '</div>');
        $(document.body).append($dom);
        GOVUK.validation.init();
        GOVUK.willItWorkForMe.init();
        willItWorkForMeForm = GOVUK.willItWorkForMe.$form;
        this.submitForm = function () {
            willItWorkForMeForm.triggerHandler('submit');
        };
        this.selectAboveAgeThreshold = function () {
            this.checkRadio(willItWorkForMeForm.find('input[name="will_it_work_for_me_form[above_age_threshold]"][value=true]'));
        };
        this.selectResident12Months = function () {
            this.checkRadio(willItWorkForMeForm.find('input[name="will_it_work_for_me_form[resident_last_12_months]"][value=true]'));
        };
        this.selectNotResident12Months = function () {
            this.checkRadio(willItWorkForMeForm.find('input[name="will_it_work_for_me_form[resident_last_12_months]"][value=false]'));
        };
        this.selectNoUKAddress = function () {
            this.checkRadio(willItWorkForMeForm.find('input[name="will_it_work_for_me_form[not_resident_reason]"][value=NoAddress]'));
        };

        this.checkRadio = function (el) {
            el.prop('checked', true).trigger('click');
        };
    });

    function submitForm() {
        wilItWorkForMeForm.triggerHandler('submit')
    }

    function expectErrorMessage() {
        expect(willItWorkForMeForm.find('#validation-error-message-js').text()).toBe("Please answer all the questions");
    }

    function expectNoError() {
        expect(willItWorkForMeForm.children('.form-group:first').is('.govuk-form-group--error')).toBe(false);
        expect(willItWorkForMeForm.find('#validation-error-message-js').text()).toBe('');
    }

    afterEach(function () {
        $dom.remove();
    });

    it("should have no errors on initialising the form.", function () {
        expectNoError();
    });

    it("should not initially show 'not-resident-reason' section.", function () {
        expect(willItWorkForMeForm.find('#conditional-will_it_work_for_me_form_resident_last_12_months_false').attr("class")).toContain("govuk-radios__conditional--hidden");
    });

    it("should have errors on submit if user does not answer any questions", function () {
        this.submitForm();
        expect(willItWorkForMeForm.children('#above-age-threshold').attr("class")).toContain('error');
        expect(willItWorkForMeForm.children('#resident_last_12_months').attr("class")).toContain('error');
        expectErrorMessage();
    });

    it("should have errors on submit if user does not answer over the age threshold", function () {
        this.selectNotResident12Months();
        this.submitForm();
        expect(willItWorkForMeForm.children('#above-age-threshold').attr("class")).toContain('error');
        expectErrorMessage();
    });

    it("should have errors on submit if the residency question isn't answered", function () {
        this.selectAboveAgeThreshold();
        this.submitForm();
        expect(willItWorkForMeForm.children('#resident_last_12_months').attr("class")).toContain('error');
        expectErrorMessage();
    });

    it("should have errors on submit if user indicates not resident for 12 months and does not supply reason", function () {
        this.selectNotResident12Months();
        this.submitForm();
        expect($('#conditional-will_it_work_for_me_form_resident_last_12_months_false').children('.govuk-form-group').attr('class')).toContain('error');
        expectErrorMessage();
    });

    it("should have no errors on submit if user has answered over age threshold and lived in UK for 12 months", function () {
        this.selectAboveAgeThreshold();
        this.selectResident12Months();

        this.submitForm();

        expectNoError();
    });

    it("should have no errors on submit if user has answered above age threshold and lived in UK for 12 months and has chosen the reason", function () {
        this.selectAboveAgeThreshold();
        this.selectNotResident12Months();
        this.selectNoUKAddress();

        this.submitForm();

        expectNoError();
    });
});
