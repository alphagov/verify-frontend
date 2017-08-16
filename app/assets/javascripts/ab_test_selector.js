function abTest(experimentDetails) {

  try {
    if (document.cookie.indexOf("ab_test") >= 0) {
      const abCookie = JSON.parse(getCookie("ab_test"))

      var routes = { 'control': experimentDetails.control.route}

      experimentDetails.alternatives.forEach(function(alternative){
        routes[experimentDetails.experiment.concat('_' + alternative.name)] = alternative.route
      })

      if (routes[[abCookie[experimentDetails.experiment]]]) {
        routes[abCookie[experimentDetails.experiment]].init();
      } else {
        experimentDetails.control.route.init();
      }
    } else {
      experimentDetails.control.route.init();
    }
  }
  catch(err) {
    experimentDetails.control.route.init();
  }
}

function getCookie(cname) {
  var name = cname + "=";
  var decodedCookie = decodeURIComponent(document.cookie);
  var ca = decodedCookie.split(';');
  for(var i = 0; i <ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}