//= require jquery
//= require sign_in
//= require mock-ajax

describe('The sign in page', function () {
  var $dom,
      $formButton,
      apiPath = '/select-idp',
      formSpy,
      html = '<div class="js-idp-option-container">'
           + '<form class="idp-option first-form" action="">'
           +   '<button type=submit name=IDCorp value="IDCorpDisplayName"></button>'
           + '</form>'
           + '<form class="idp-option second-form" action="">'
           +   '<button type=submit name=IDCorpZwei value="IDCorpZweiDisplayName"></button>'
           + '</form>'
           + '<form id=post-to-idp>'
           +   '<input name=SAMLRequest type=hidden>'
           +   '<input name=RelayState type=hidden>'
           +   '<input type=submit>'
           + '</form>'
           + '</div>';


  beforeEach(function () {
    $dom = $('<div>'+html+'</div>');
    $(document.body).append($dom);
    $formButton = $('.idp-option button[name=IDCorpZwei]');
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
      jasmine.Ajax.stubRequest(apiPath);
      $formButton.click();
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        responseText: JSON.stringify({
          saml_request: 'a-saml-request',
          location: 'https://www.example.com'
        })
      });
      expect(jasmine.Ajax.requests.mostRecent().url).toBe(apiPath);
      expect(jasmine.Ajax.requests.mostRecent().params).toBe('{"entityId":"IDCorpZwei","displayName":"IDCorpZweiDisplayName"}');
    });
    it('should populate the SAML request form with the AJAX response and submit it', function () {
      $(document).submit(formSpy);
      jasmine.Ajax.stubRequest(apiPath);

      $formButton.click();
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        responseText: JSON.stringify({
          saml_request: 'a-saml-request',
          location: 'https://www.example.com'
        })
      });
      expect(jasmine.Ajax.requests.mostRecent().url).toBe(apiPath);
      var $samlForm = $('#post-to-idp');

      expect($samlForm.prop('action')).toBe('https://www.example.com/');
      expect($samlForm.find('input[name=SAMLRequest]').val()).toBe('a-saml-request');
      expect(formSpy).toHaveBeenCalled();
    });
    it('should submit IDP choice if AJAX request fails', function () {
      var selectIdpFormSubmitted = [];
      $(document).submit(function(e) {
        e.preventDefault();
        selectIdpFormSubmitted.push(e.target.className);
      });
      jasmine.Ajax.stubRequest(apiPath);

      $formButton.click();
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 500,
        responseText: JSON.stringify({})
      });

      expect(selectIdpFormSubmitted.length).toBe(1);
      expect(selectIdpFormSubmitted[0]).toContain("second-form");
    });
    it('should throw an error if PUT responds with 200, but malformed content', function () {
      jasmine.Ajax.stubRequest(apiPath);
      $formButton.click();

      var response = {
        status: 200,
        responseText: JSON.stringify({})
      };
      expect(function() {
        jasmine.Ajax.requests.mostRecent().respondWith(response);
      }).toThrow();
    })
  });
});
