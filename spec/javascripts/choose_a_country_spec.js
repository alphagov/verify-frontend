describe('The choose a country page', function () {
  var $dom;
  var html =
    '<form id="form-no-js" class="js-hidden">' +
      '<select name="country" id="js-disabled-country-picker" class="form-control-2-3 form-control">' +
        '<option value=""></option>' +
        '<option value="FR">France</option>' +
        '<option value="DE">Germany</option>' +
      '</select>' +
      '<input class="button" type="submit" value="Select"/>' +
    '</form>' +
    '<form id="form-js" class="js-show">' +
      '<div id="country-picker" class="form-control-2-3"></div>' +
      '<input type="hidden" name="country">' +
      '<input class="button" type="submit" value="Select"/>' +
    '</form>' +
    '<div id="no-country" style="display: none;">' +
      '<h2 class="heading-medium">Please select a country from the list</h2>' +
      '<p><a href="javascript:history.back()">Try another way to sign in.</a>' +
      '</p>' +
    '</div>';

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

    setTimeout(function () {
      var options = $dom.find('.typeahead__option');
      expect(options.length).toBe(1);

      var option0 = $dom.find('#typeahead__option--0');

      expect(option0.length).toBe(1);
      expect(option0.text()).toBe('Germany');

      done();
    }, 0);
  });

  it('should suggest France when the user enters "Fr"', function (done) {
    var typeahead = document.getElementById('typeahead');
    typeahead.value = 'Fr';
    typeahead.dispatchEvent(new Event('input'));

    setTimeout(function () {
      var options = $dom.find('.typeahead__option');
      expect(options.length).toBe(1);

      var option0 = $dom.find('#typeahead__option--0');

      expect(option0.length).toBe(1);
      expect(option0.text()).toBe('France');

      done();
    }, 0);
  });

  it('should suggest Germany and France when the user enters "an"', function (done) {
    var typeahead = document.getElementById('typeahead');
    typeahead.value = 'an';
    typeahead.dispatchEvent(new Event('input'));

    setTimeout(function () {
      var options = $dom.find('.typeahead__option');
      expect(options.length).toBe(2);

      var option0 = $dom.find('#typeahead__option--0');
      var option1 = $dom.find('#typeahead__option--1');

      expect(option0.length).toBe(1);
      expect(option0.text()).toBe('France');
      expect(option1.length).toBe(1);
      expect(option1.text()).toBe('Germany');

      done();
    }, 0);
  });

  it('should not submit form and show country not found error when the user enters invalid country', function (done) {
    var typeahead = document.getElementById('typeahead');
    typeahead.value = 'invalid-country';
    var $form = $dom.find('form.js-show');

    // NOTE: Unable to assert the form/document is not submitted using spy because of lack of
    //       event attachment point (a parent).  Possible solution is to capture the event and
    //       check it is marked as 'preventDefault'.
    $form.on('submit', function () {
      expect($dom.find('#no-country').is(':visible')).toBe(true);
      done();
      return false;
    });

    $form.submit();
  });

  it('should submit country=DE when the user selects Germany', function (done) {
    var typeahead = document.getElementById('typeahead');
    var $form = $dom.find('form.js-show');

    var formSpy = jasmine.createSpy('formSpy');
    $dom.on('submit', formSpy);

    typeahead.value = 'Germany';
    $dom.on('submit', function (event) {
      expect($dom.find('input[name=country]').val()).toBe('DE');
      expect(formSpy).toHaveBeenCalled();
      done();
      return false;
    });

    $form.submit();
  });
});
