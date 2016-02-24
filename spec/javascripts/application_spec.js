//= require application
describe('The main JS file', function () {
  it('should include jQuery', function () {
    expect(window.jQuery).toBeDefined();
  });
  it('should include jQuery validation', function () {
    expect($.fn.validate).toBeDefined();
  });
  it('should include the GOVUK validation module', function () {
    expect(window.GOVUK.validation).toBeDefined();
  });
});
