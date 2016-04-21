//= require jquery
//= require trap
//= require dialog

describe("Dialog", function () {

  var dialogDom = '<a class="js-show js-dialog" href="#about-idp">About IDCorp</a>' +
    '<dialog style="display:none;" id="about-idp">' +
    '<a href="#" class="dialog-close js-dialog-close" role="button">close</a>' +
    '</dialog>';

  var $dom;
  var dialog;
  $('html').addClass('js-enabled');

  beforeEach(function () {
    $dom = $('<div>' + dialogDom + '</div>');
    $(document.body).append($dom);
    GOVUK.dialog.init();
  });

  afterEach(function () {
    $dom.remove();
  });

  it("should show about information for idp when about link is clicked", function () {
    $('.js-dialog').click();
    expect($('dialog').is('[open]')).toBe(true);
  });

  it("should hide about information for idp when close link is clicked", function () {
    $('.js-dialog').click();
    $('.js-dialog-close').click();
    expect($('dialog').is('[open]')).toBe(false);
  });
});
