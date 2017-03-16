describe('The choose a country page', function () {
  var $dom;
  var html =
    '<form class="js-hidden">' +
      '<select name="country" id="js-disabled-country-picker" class="form-control-2-3 form-control">' +
        '<option value=""></option>' +
        '<option value="FR">France</option>' +
        '<option value="DE">Germany</option>' +
      '</select>' +
      '<input class="button" type="submit" value="Select"/>' +
    '</form>' +
    '<form class="js-show">' +
      '<div id="country-picker" class="form-control-2-3"></div>' +
      '<input type="hidden" name="country">' +
      '<input class="button" type="submit" value="Select"/>' +
    '</form>';

  beforeEach(function () {
    $dom = $('<div>' + html + '</div>');
    $(document.body).append($dom);
    GOVUK.chooseACountry.attach();
  });

  afterEach(function () {
    $dom.remove();
  });

  it('should suggest Germany when the user enters "Ge"', function (done) {
    var typeahead = document.getElementById('typeahead');
    typeahead.value = 'Ge';
    typeahead.dispatchEvent(new Event('input'));

    requestAnimationFrame(function () {
      var options = $dom.find('.typeahead__option');
      expect(options.length).toBe(1);

      var option0 = $dom.find('#typeahead__option--0');

      expect(option0.length).toBe(1);
      expect(option0.text()).toBe('Germany');

      done();
    });
  });

  it('should suggest France when the user enters "Fr"', function (done) {
    var typeahead = document.getElementById('typeahead');
    typeahead.value = 'Fr';
    typeahead.dispatchEvent(new Event('input'));

    requestAnimationFrame(function () {
      var options = $dom.find('.typeahead__option');
      expect(options.length).toBe(1);

      var option0 = $dom.find('#typeahead__option--0');

      expect(option0.length).toBe(1);
      expect(option0.text()).toBe('France');

      done();
    });
  });

  it('should suggest Germany and France when the user enters "an"', function (done) {
    var typeahead = document.getElementById('typeahead');
    typeahead.value = 'an';
    typeahead.dispatchEvent(new Event('input'));

    requestAnimationFrame(function () {
      var options = $dom.find('.typeahead__option');
      expect(options.length).toBe(2);

      var option0 = $dom.find('#typeahead__option--0');
      var option1 = $dom.find('#typeahead__option--1');

      expect(option0.length).toBe(1);
      expect(option0.text()).toBe('France');
      expect(option1.length).toBe(1);
      expect(option1.text()).toBe('Germany');

      done();
    });
  });

  it('should submit country=DE when the user selects Germany', function (done) {
    var typeahead = document.getElementById('typeahead');
    var $form = $('form');

    typeahead.value = 'Germany';
    $form.submit(function () {
      expect($dom.find('input[name=country]').val()).toBe('DE');
      done();
    });

    $form.submit();
  });
});
