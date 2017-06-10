function abTest(experimentDetails) {

  const routeB = experimentDetails.experiment.concat('_variant')

  try {
    if (document.cookie.indexOf("ab_test") >= 0) {
      const abCookie = JSON.parse(getCookie("ab_test"))

      if (abCookie.app_transparency === routeB) {
        experimentDetails.routeB.init();
      } else {
        experimentDetails.routeA.init();
      }
    } else {
      experimentDetails.routeA.init();
    }
  }
  catch(err) {
    experimentDetails.routeA.init();
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