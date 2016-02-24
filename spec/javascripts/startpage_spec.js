//= require application
describe('The start page', function () {
  var formSpy;
  var $dom = $(
        '<form>'
      +   '<input type=radio id=yes>'
      +   '<input type=radio id=no>'
      +   '<input type=submit>'
      + '</form>'
      );

  beforeEach(function () {
    $(document.body).append($dom);
    formSpy = jasmine.createSpy('formSpy')
      .and
      .callFake(function (e) { e.preventDefault(); });
  });

  afterEach(function () {
    $dom.remove();
  });

  describe('when the user selects an option and submits the form', function () {
    it('should submit successfully', function () {
      $('#yes').prop('checked', true);
      $(document).submit(formSpy);
      $('form').submit();
      expect(formSpy).toHaveBeenCalled();
    });
  });
});
