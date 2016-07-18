//= require jquery
//= require vendor/jquery.validate
//= require vendor/jquery.validate.pattern
//= require validation
//= require further_information

describe("Further Information Form", function () {

  var formWithNoErrors =
    '<form id="further-information" novalidate="novalidate">' +
      '<div class="form-group">' +
        '<label for="cycle_three_form_cycle_three_data">' +
        'Enter your National Insurance number' +
        '</label>' +
        '<input required="required" pattern="^pear$" type="text" id="cycle_three_form_cycle_three_data" data-msg="validation message">' +
      '</div>' +
    '<input type="submit" value="Continue" id="cycle_three_submit" class="button">' +
    '</form>';

  var formWithCheckbox =
      '<form id="further-information" novalidate="novalidate">' +
        '<div class="form-group">' +
            '<label for="cycle_three_form_cycle_three_data">' +
                'Enter your National Insurance number' +
            '</label>' +
            '<input required="required" pattern="^pear$" type="text" id="cycle_three_form_cycle_three_data" data-msg="validation message">' +
        '</div>' +
        '<div class="form-group">' +
            '<label for="cycle_three_form_null_attribute">' +
                'I don\'t have a National Insurance number' +
            '</label>' +
            '<input type="checkbox" id="cycle_three_form_null_attribute">' +
        '</div>' +
        '<input type="submit" value="Continue" id="cycle_three_submit" class="button">' +
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

  function furtherInformationFormWithCheckbox() {
    $dom.remove();
    $dom = $('<div>' + formWithCheckbox + '</div>');
    $(document.body).append($dom);
    GOVUK.validation.init();
    GOVUK.furtherInformation.init();
    return GOVUK.furtherInformation.$form;
  }

  it("should have no errors on initialising the form.", function () {
    expect(furtherInformationForm.find('.error').length).toBe(0);
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

  it("should have no errors when nullable attribute field is checked", function () {
    furtherInformationForm =  furtherInformationFormWithCheckbox();
    furtherInformationForm.find('input[type=checkbox]').trigger('click');
    expect(furtherInformationForm.find('input[formnovalidate=formnovalidate]').size()).toBe(1);
  });

  it("validation should trigger when checkbox toggled", function () {
    furtherInformationForm =  furtherInformationFormWithCheckbox();
    furtherInformationForm.find('input[type=checkbox]').trigger('click');
    furtherInformationForm.find('input[type=checkbox]').trigger('click');
    expect(furtherInformationForm.find('input[formnovalidate=formnovalidate]').size()).toBe(0);
    submitForm();
    expect(furtherInformationForm.find('.error-message').eq(0).text()).toBe('validation message');
  });
});
