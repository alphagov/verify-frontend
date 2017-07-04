(function(global) {
  "use strict";
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;

  // Ensure that the fingerprint epoch is increased whenever the algorithm is changed
  // in any way - this will ensure that we compare like with like
  var epoch = 5;

  // disabling javascript font parsing, this is very slow, and the canvas because it yields a different fingerprint for the first page loaded
  var options = {excludeJsFonts: true, excludeCanvas: true};

  // By default Fingerprint2 logs things to the console. This setting disables logging:
  global.NODEBUG = null;

  // based on jQuery's param implementation https://github.com/jquery/jquery/blob/master/src/serialize.js
  function serialiseComponents(components) {
    var componentsToExclude = ['webgl'];
    var r = [];
    global.jQuery.each(components, function() {
      if(componentsToExclude.indexOf(this.key) === -1) {
        r[r.length] = encodeURIComponent(this.key) + "=" + encodeURIComponent(this.value);
      }
    });
    return r.join("&");
  }

  GOVUK.fingerprint = {
    attach: function () {
      $('#fp_img').remove();
      var path = $('main').data('fp-path');
      new Fingerprint2(options).get(function(result, components){
        var imageElement = document.createElement('img');
        imageElement.setAttribute('id', 'fp_img');
        imageElement.setAttribute('style', 'left: -9999px; position: absolute; border:0');
        imageElement.setAttribute('height', '1');
        imageElement.setAttribute('width', '1');
        imageElement.setAttribute('src', path + '?hash='+epoch+'-'+result+'&cache_bust='+(new Date().getTime())+'&'+serialiseComponents(components));
        document.body.appendChild(imageElement);
      });
    }
  };

  global.GOVUK = GOVUK;
})(window);