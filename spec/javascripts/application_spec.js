//= require application
describe("The main JS file", function () {
  it("should include jQuery", function () {
    expect(window.jQuery).toBeDefined();
  });
  it("should include jQuery validation", function () {
    expect($.fn.validate).toBeDefined();
  });
});
