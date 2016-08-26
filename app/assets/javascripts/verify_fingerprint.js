//= require fingerprint2

(function(global) {
   'use strict';

    // By default Fingerprint2 logs things to the console. This setting disables logging:
    global.NODEBUG = null;

    // based on jQuery's param implementation https://github.com/jquery/jquery/blob/master/src/serialize.js
    function serialiseComponents(components) {
        var componentsToExclude = ['webgl'];
        var r = [];
        global.jQuery.each(components, function() {
            if(componentsToExclude.indexOf(this.key) == -1) {
                r[r.length] = encodeURIComponent(this.key) + "=" + encodeURIComponent(this.value);
            }
        });
        return r.join("&");
    }

    function reportFingerprint(path, epoch, imageElement) {
        // disabling javascript font parsing, this is very slow, and the canvas because it yields a different fingerprint for the first page loaded
        var options = {excludeJsFonts: true, excludeCanvas: true};
        new Fingerprint2(options).get(function(result, components){
            imageElement.src = path + '?hash='+epoch+'-'+result+'&cache_bust='+(new Date().getTime())+'&'+serialiseComponents(components);
        });
    }

    global.reportFingerprint = reportFingerprint;
})(window);
