describe("Further Information Form", function () {

  var formWithNoErrors =
    '<form id="further-information" novalidate="novalidate">' +
      '<div class="form-group">' +
        '<label for="cycle_three_attribute_cycle_three_data">' +
        'Enter your National Insurance number' +
        '</label>' +
        '<input required="required" pattern="^pear$" type="text" id="cycle_three_attribute_cycle_three_data" data-msg="validation message">' +
      '</div>' +
    '</form>';

  var furtherInformationForm;
  var $dom;

  function submitForm() {
    furtherInformationForm.triggerHandler('submit');
  }

  function expectNoError() {
    expect(furtherInformationForm.find('.error, .error-message').length).toBe(0);
  }

  beforeEach(function () {
    $dom = $('<div>' + formWithNoErrors + '</div>');
    $(document.body).append($dom);
    GOVUK.validation.init();
    GOVUK.furtherInformation.init();
    furtherInformationForm = GOVUK.furtherInformation.$form;
  });

  afterEach(function () {
    $dom.remove();
  });

  it("should have no errors on initialising the form.", function () {
    expect(furtherInformationForm.find('.form-group-error').length).toBe(0);
  });

  it("should have errors on submit when no details entered.", function () {
    submitForm();
    expect(furtherInformationForm.find('.error-message').eq(0).text()).toBe('validation message');
  });

  it("should have errors on submit when non-matching details entered.", function () {
    furtherInformationForm.find('input').val('banana');
    submitForm();
    expect(furtherInformationForm.find('.error-message').eq(0).text()).toBe('validation message');
  });

  it("should have no errors with correct details", function () {
    furtherInformationForm.find('input').val('pear');
    submitForm();
    expectNoError();
  });
});
