describe('The start page', function () {
  var $dom,
    formSpy,
    html = '<form id="start-page-form" class="js-validate" novalidate="novalidate" action="/start" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="authenticity_token" value="zVsV/kc37UALs+lkjpiy4G0kxRdCQo/Wx9J3dYVfuFraSHJHjtnwsVpMx1p+Y6ij1Zx5k0LdaeydpeVl5msGcQ==" />' +
      '<div class="govuk-form-group">' +
      '<fieldset class="govuk-fieldset">' +
      '<div class="govuk-radios">' +
      '<div class="govuk-radios__item">' +
      '<input required="required" data-msg="Test error message" piwik_event_tracking="journey_user_type" class="govuk-radios__input" type="radio" value="true" name="start_form[selection]" id="start_form_selection_true" />' +
      '<label class="govuk-label govuk-radios__label" for="start_form_selection_true">This is my first time using GOV.UK Verify</label>' +
      '</div>' +
      '<div class="govuk-radios__item">' +
      '<input required="required" data-msg="Test error message" piwik_event_tracking="journey_user_type" class="govuk-radios__input" type="radio" value="false" name="start_form[selection]" id="start_form_selection_false" />' +
      '<label class="govuk-label govuk-radios__label" for="start_form_selection_false">I’ve used GOV.UK Verify before</label>' +
      '</div>' +
      '</div>' +
      '</fieldset>' +
      '</div>' +
      '<div id="validation-error-message-js"></div>' +
      '<div class="form-group-tight">' +
      '<div class="actions">' +
      '<input type="submit" name="commit" value="Continue" class="govuk-button verify-inverse-btn" id="next-button" />' +
      '</div>' +
      '</div>' +
      '</form>';

  beforeEach(function () {
    $dom = $(html);
    $(document.body).append($dom);
    window.GOVUK.validation.init();
    window.GOVUK.validation.attach();
    formSpy = jasmine.createSpy('formSpy')
      .and.callFake(function (e) { e.preventDefault(); });
  });

  afterEach(function () {
    $dom.remove();
    $(document).off('submit');
  });

  describe('when the user selects an option and submits the form', function () {
    it('should submit successfully', function () {
      $('#start_form_selection_true').prop('checked', true);
      $(document).submit(formSpy);
      $('form').submit();
      expect(formSpy).toHaveBeenCalled();
      expect($('.govuk-form-group').hasClass('govuk-form-group--error')).toBe(false);
    });
  });

  describe('when the user submits without selecting an option', function () {
    it('should display an error message and prevent submission', function () {
      $(document).submit(formSpy);
      $('form').submit();
      expect(formSpy).not.toHaveBeenCalled();
      expect($('.govuk-form-group').hasClass('govuk-form-group--error')).toBe(true);
      expect($('#validation-error-message-js').text()).toBe('Test error message')
    });
  });

  describe('when the form has errors and the user selects an option', function () {
    var $formGroup;

    beforeEach(function () {
      $formGroup = $('.govuk-form-group');
      $(document).submit(formSpy);
      $('form').submit();
    });

    it('should remove the error message and highlights', function () {
      expect($formGroup.hasClass('govuk-form-group--error')).toBe(true);
      $('#start_form_selection_true').prop('checked', true).click();
      expect($formGroup.hasClass('govuk-form-group--error')).toBe(false);
    });
  });
});
