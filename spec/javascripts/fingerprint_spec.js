describe("Fingerprint", function () {

  var mainElement =
    '<main data-fp-path="/test">' +
    '</main>';

  var $fingerprintImg;
  var $dom;

  afterEach(function () {
    $dom.remove();
  });

  it("src should contain path from main element data-fp-path attribute", function () {
    $dom = $(mainElement);
    $(document.body).append($dom);
    GOVUK.fingerprint.attach();
    $fingerprintImg = $('#fp_img');
    expect($fingerprintImg.attr('src')).toContain('test');
  });
});
