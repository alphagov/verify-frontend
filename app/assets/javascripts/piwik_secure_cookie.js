(function(global){
  global.GOVUK.piwikSecureCookie = {
    init: function() {
        _paq.push(['setSecureCookie', global.location.protocol === 'https:']);
    }
}
})(window);
