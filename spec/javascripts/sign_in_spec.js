//= require sign_in
//= require mock-ajax

describe('The sign in page', function () {
  var $dom,
      formSpy,
      html = '<form class=select-idp-form action="">'
           +   '<button type=submit value=IDCorp></button>'
           + '</form>'
           + '<form id=post-to-idp>'
           +   '<input name=SAMLRequest type=hidden>'
           +   '<input name=RelayState type=hidden>'
           +   '<input type=submit>'
           + '</form>';


  beforeEach(function () {
    $dom = $('<div>'+html+'</div>');
    $(document.body).append($dom);
    window.GOVUK.signin.attach();
    formSpy = jasmine.createSpy('formSpy')
      .and.callFake(function (e) { e.preventDefault(); });
    jasmine.Ajax.install();
  });

  afterEach(function () {
    $dom.remove();
    jasmine.Ajax.uninstall();
    $(document).off('submit');
  });

  describe('when the form is submitted', function () {
    it('should PUT via AJAX to /select-idp', function () {
      $(document).submit(formSpy);
      jasmine.Ajax.stubRequest('/api/select-idp');

      $('.select-idp-form button').click();
      expect(formSpy).not.toHaveBeenCalled();
      expect(jasmine.Ajax.requests.mostRecent().url).toBe('/api/select-idp');
    });
    it('should populate the SAML request form with the AJAX response and submit it', function () {
      $(document).submit(formSpy);
      jasmine.Ajax.stubRequest('/api/select-idp');

      $('.select-idp-form button').click();
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        responseText: JSON.stringify({
          samlRequest: 'a-saml-request',
          location: 'https://www.example.com'
        })
      });
      expect(jasmine.Ajax.requests.mostRecent().url).toBe('/api/select-idp');
      var $samlForm = $('#post-to-idp');

      expect($samlForm.prop('action')).toBe('https://www.example.com/');
      expect($samlForm.find('input[name=SAMLRequest]').val()).toBe('a-saml-request');
      expect(formSpy).toHaveBeenCalled();
    });
    it('should submit IDP choice if AJAX request fails', function () {
      var selectIdpFormSubmitted = false;
      $(document).submit(function(e) {
        e.preventDefault();
        if (e.target.className === 'select-idp-form') {
          selectIdpFormSubmitted = true;
        }
      });
      jasmine.Ajax.stubRequest('/api/select-idp');

      $('.select-idp-form button').click();
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 500,
        responseText: JSON.stringify({})
      });

      expect(selectIdpFormSubmitted).toBe(true);
    });
  });
});