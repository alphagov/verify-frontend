describe("Will it work for me form", function () {
    //$('html').addClass('js-enabled');

    var formWithNoErrors =
        '<form method="POST" action="" id="validate-will-it-work-for-me" data-msg="Please answer all the questions">' +
        '<div id="above-age-threshold" class="form-group">' +
        '<fieldset class="inline">' +
        '<legend>Are you 20 or over?</legend>' +
        '<label class="block-label" onclick="" for="age-yes">' +
        '<input id="will_it_work_for_me_form_above_age_threshold_true" name="will_it_work_for_me_form[above_age_threshold]" type="radio" value="true">' +
        '<span><span class="inner">&nbsp;</span></span>Yes' +
        '</label>' +
        '<label class="block-label" onclick="" for="age-no">' +
        '<input id="will_it_work_for_me_form_above_age_threshold_false" name="will_it_work_for_me_form[above_age_threshold]" type="radio" value="false">' +
        '<span><span class="inner">&nbsp;</span></span>No' +
        '</label>' +
        '</fieldset>' +
        '</div>' +
        '<div id="resident_last_12_months" class="form-group">' +
        '<fieldset class="inline"><legend>Have you lived in the UK for the last 12 months?</legend>' +
        '<label class="block-label" onclick="" for="resident-last-12-months">' +
        '<input id="will_it_work_for_me_form_resident_last_12_months_true" name="will_it_work_for_me_form[resident_last_12_months]" type="radio" value="true">' +
        '<span><span class="inner">&nbsp;</span></span>Yes' +
        '</label>' +
        '<label class="block-label" onclick="" for="not-resident-last-12-months">' +
        '<input id="will_it_work_for_me_form_resident_last_12_months_false" name="will_it_work_for_me_form[resident_last_12_months]" type="radio" value="false">' +
        '<span><span class="inner">&nbsp;</span></span>No' +
        '</label>' +
        '</fieldset>' +
        '</div>' +
        '<div class="form-group" id="not_resident_reason">' +
        '<fieldset>' +
        '<legend>Which of these applies to you?</legend>' +
        '<label class="block-label" onclick="" for="moved-to-uk-in-last-12-months">' +
        '<input id="will_it_work_for_me_form_not_resident_reason_movedrecently" name="will_it_work_for_me_form[not_resident_reason]" type="radio" value="MovedRecently">' +
        '<span><span class="inner">&nbsp;</span></span>I moved to the UK in the last 12 months' +
        '</label>' +
        '<label class="block-label" onclick="" for="has-uk-address">' +
        '<input id="will_it_work_for_me_form_not_resident_reason_addressbutnotresident" name="will_it_work_for_me_form[not_resident_reason]" type="radio" value="AddressButNotResident">' +
        '<span><span class="inner">&nbsp;</span></span>I have an address in the UK but I don&rsquo;t live there' +
        '</label>' +
        '<label class="block-label" onclick="" for="no-uk-address">' +
        '<input id="will_it_work_for_me_form_not_resident_reason_noaddress" name="will_it_work_for_me_form[not_resident_reason]" type="radio" value="NoAddress">' +
        '<span><span class="inner">&nbsp;</span></span>I don&rsquo;t have a UK address' +
        '</label>' +
        '</fieldset>' +
        '</div>' +
        '<div id="validation-error-message-js"></div>' +
        '<div class="form-group">' +
        '<input class="button" id="next-button" type="submit" value="Continue">' +
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
        expect(willItWorkForMeForm.children('.form-group:first').is('.error')).toBe(false);
        expect(willItWorkForMeForm.find('#validation-error-message-js').text()).toBe('');
    }

    afterEach(function () {
        $dom.remove();
    });

    it("should have no errors on initialising the form.", function () {
        expectNoError();
    });

    it("should not initially show 'not-resident-reason' section.", function () {
        expect(willItWorkForMeForm.find('#not_resident_reason').attr("class")).toContain("js-hidden");
    });

    it("should show 'not-resident-reason' section when user indicates no residency for 12 months", function () {
        this.selectNotResident12Months();

        expect(willItWorkForMeForm.find('#not_resident_reason').attr("class")).not.toContain("js-hidden");
    });

    it("should not show 'not-resident-reason' section when user indicates residency for 12 months", function () {
        this.selectResident12Months();

        expect(willItWorkForMeForm.find('#not_resident_reason').attr("class")).toContain("js-hidden");
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
        expect(willItWorkForMeForm.children('#not_resident_reason').attr("class")).toContain('error');
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
