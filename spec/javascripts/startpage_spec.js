//= require application
describe('The start page', function () {
  var $dom,
      formSpy,
      html = '<form id="start-page-form">'
           +   '<input name=selection type=radio id=yes>'
           +   '<input name=selection type=radio id=no>'
           +   '<input type=submit>'
           + '</form>';

  beforeEach(function () {
    $dom = $(html);
    $(document.body).append($dom);
    window.GOVUK.validation.init();
    window.GOVUK.startPage.init();
    formSpy = jasmine.createSpy('formSpy')
      .and.callFake(function (e) { e.preventDefault(); });
  });

  afterEach(function () { $dom.remove(); });

  describe('when the user selects an option and submits the form', function () {
    it('should submit successfully', function () {
      $('#yes').prop('checked', true);
      $(document).submit(formSpy);
      $('form').submit();
      expect(formSpy).toHaveBeenCalled();
    });
  });

  describe('when the user submits without selecting an option', function () {
    it('should display an error message and prevent submission', function () {
      $(document).submit(formSpy);
      $('form').submit();
      expect(formSpy).not.toHaveBeenCalled();
    });
  });
});
