//= require application
describe('The start page', function () {
  var $dom,
      formSpy,
      html = '<form id="start-page-form" class="js-validate" novalidate>'
           +   '<div class="form-group">'
           +     '<input name=selection type=radio id=yes required data-msg="Test error message">'
           +     '<input name=selection type=radio id=no>'
           +     '<input type=submit>'
           +   '</div>'
           +   '<div id="validation-error-message-js"></div>'
           + '</form>';

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
      $('#yes').prop('checked', true);
      $(document).submit(formSpy);
      $('form').submit();
      expect(formSpy).toHaveBeenCalled();
      expect($('.form-group').hasClass('error')).toBe(false);
    });
  });

  describe('when the user submits without selecting an option', function () {
    it('should display an error message and prevent submission', function () {
      $(document).submit(formSpy);
      $('form').submit();
      expect(formSpy).not.toHaveBeenCalled();
      expect($('.form-group').hasClass('error')).toBe(true);
      expect($('#validation-error-message-js').text()).toBe('Test error message')
    });
  });

  describe('when the form has errors and the user selects an option', function (){
    var $formGroup;

    beforeEach(function () {
      $formGroup = $('.form-group');
      $(document).submit(formSpy);
      $('form').submit();
    });

    it('should remove the error message and highlights', function () {
      expect($formGroup.hasClass('error')).toBe(true);
      $('#yes').prop('checked', true).click();
      expect($formGroup.hasClass('error')).toBe(false);
    });
  });
});
