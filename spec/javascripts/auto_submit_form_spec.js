//= require 'auto_submit_form'

describe('auto', function () {

  var $dom, formSpy;

  beforeEach(function () {
    formSpy = jasmine.createSpy('formSpy').and.callFake(function (e) { e.preventDefault(); });
    $(document).on('submit', formSpy);
  });

  afterEach(function () {
    $dom.remove();
    $(document).off('submit');
  });

  it('should leave ordinary forms alone', function () {
    $dom = $('<form><input type="submit"></form>');
    $(document.body).append($dom);
    window.GOVUK.autoSubmitForm.attach();
    expect(formSpy).not.toHaveBeenCalled();
  });

  it('should immediately submit auto-submitting forms', function () {
    $dom = $('<form class="js-auto-submit"><input type="submit"></form>');
    $(document.body).append($dom);
    window.GOVUK.autoSubmitForm.attach();
    expect(formSpy).toHaveBeenCalled();
  });
});