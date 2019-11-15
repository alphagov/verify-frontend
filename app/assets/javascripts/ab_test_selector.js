function abTest (experimentDetails) {
  try {
    if (document.cookie.indexOf("ab_test_trial") >= 0) {
      var abTrialCookie = getCookie("ab_test_trial");

      if (experimentDetails.trial_enabled && experimentDetails.experiment == abTrialCookie) {
        experimentDetails.alternatives[ 0 ].route.init();
        return
      }
    }

    if (document.cookie.indexOf("ab_test") >= 0) {
      var abCookie = JSON.parse(getCookie("ab_test"));

      var routes = { 'control': experimentDetails.control.route };

      for(var i = 0; i < experimentDetails.alternatives.length; i++) {
          var alternative = experimentDetails.alternatives[i];
          routes[ experimentDetails.experiment.concat('_' + alternative.name) ] = alternative.route;
      }

      if (routes[ [ abCookie[ experimentDetails.experiment ] ] ]) {
        routes[ abCookie[ experimentDetails.experiment ] ].init();
      } else {
        experimentDetails.control.route.init();
      }
    } else {
      experimentDetails.control.route.init();
    }
  }
  catch (err) {
    experimentDetails.control.route.init();
  }
}

function getCookie (cname) {
  var name = cname + "=";
  var decodedCookie = decodeURIComponent(document.cookie);
  var ca = decodedCookie.split(';');
  for (var i = 0; i < ca.length; i++) {
    var c = ca[ i ];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}