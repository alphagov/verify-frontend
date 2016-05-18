//= require jquery
//= require continue_to_idp.js
//= require mock-ajax

describe('Continue to IDP', function () {
  var $dom,
      $formButton,
      apiPath = '/foobar',
      formSpy,
      html = '<div class="js-continue-to-idp" data-location="/foobar">'
           + '<form class="js-idp-form first-form" action="">'
           +   '<button type=submit value="IDCorpDisplayName"></button>'
           +   '<input class=js-entity-id type="hidden" value="idcorp-entity-id" name="identity_provider[entity_id]">'
           +   '<input class=js-simple-id type="hidden" value="idcorp-simple-id" name="identity_provider[simple_id]">'
           +   '<input class=js-display-name type="hidden" value="IDCorp display name" name="identity_provider[display_name]">'
           + '</form>'
           + '<form class="js-idp-form second-form" action="">'
           +   '<button type=submit value="IDCorpZweiDisplayName"></button>'
           +   '<input class=js-entity-id type="hidden" value="idcorpzwei-entity-id" name="identity_provider[entity_id]">'
           +   '<input class=js-simple-id type="hidden" value="idcorpzwei-simple-id" name="identity_provider[simple_id]">'
           +   '<input class=js-display-name type="hidden" value="IDCorp Zwei display name" name="identity_provider[display_name]">'
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
    $formButton = $('.js-idp-form button').eq(1);
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
    it('should PUT via AJAX to /foobar', function () {
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
      expect(jasmine.Ajax.requests.mostRecent().params).toBe('{"entityId":"idcorpzwei-entity-id","displayName":"IDCorp Zwei display name","simpleId":"idcorpzwei-simple-id"}');
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
