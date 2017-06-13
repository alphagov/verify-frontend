
describe('AB Test Selector', function () {

  var EXPERIMENT_NAME = 'app_transparency'
  var VARIANT_EXPERIMENT = EXPERIMENT_NAME + '_variant'
  var CONTROL_EXPERIMENT = EXPERIMENT_NAME + '_control'
  var VARIANT_COOKIE = encodeURI("ab_test={\"" + EXPERIMENT_NAME + "\":\""  + VARIANT_EXPERIMENT + "\"}");
  var CONTROL_COOKIE = encodeURI("ab_test={\"" + EXPERIMENT_NAME + "\":\""  + CONTROL_EXPERIMENT + "\"}");
  var NOT_AB_COOKIE = encodeURI("random_cookie={\"" + EXPERIMENT_NAME + "\":\""  + CONTROL_EXPERIMENT + "\"}");
  var NO_VALUE_AB_COOKIE = "ab_test=";
  var CORRUPT_COOKIE = encodeURI("ab_test=$$$$@!£\"" + EXPERIMENT_NAME + "\":\""  + VARIANT_EXPERIMENT + "\"}");

  var ROUTE_A = 'route_a'
  var ROUTE_B = 'route_b'
  var testResult = '';

  var routeA = {
    init: function (){
      testResult = ROUTE_A
    }
  };

  var routeB = {
    init: function () {
      testResult = ROUTE_B
    }
  };

  var experimentDetails = {
    experiment: 'app_transparency',
    routeA: routeA,
    routeB: routeB
  };

  function clearCookie() {
    document.cookie.split(";").forEach(function(c) { document.cookie = c.replace(/^ +/, "").replace(/=.*/, "=;expires=" + new Date().toUTCString() + ";path=/"); });
  }

  function whenCookieIsSetTo(cookie, anotherCookie) {
    document.cookie = cookie
    if(anotherCookie) document.cookie = anotherCookie

    return {
      abTestSelectorShouldInitialise: function(route) {
        abTest(experimentDetails)

        expect(testResult).toBe(route);
      }
    };
  }

  beforeEach(function () {
    clearCookie()
    testResult = ''
  });

  it('should initialise routeA function when ab test cookie is control', function() {
    whenCookieIsSetTo(CONTROL_COOKIE).abTestSelectorShouldInitialise(ROUTE_A)
  })


  it('should initialise routeB function when ab test cookie is variant', function() {
    whenCookieIsSetTo(VARIANT_COOKIE).abTestSelectorShouldInitialise(ROUTE_B)
  })

  it('should initialise routeA function when multiple cookies exist including an ab control cookie', function() {
    whenCookieIsSetTo(CONTROL_COOKIE, "another_cookie=something_else").abTestSelectorShouldInitialise(ROUTE_A)
  })

  it('should initialise routeB function when multiple cookies exist including an ab variant cookie', function() {
    whenCookieIsSetTo(VARIANT_COOKIE, "another_cookie=something_else").abTestSelectorShouldInitialise(ROUTE_B)
  })

  it('should initialise routeA function when ab test cookie is not present', function() {
    whenCookieIsSetTo(NOT_AB_COOKIE).abTestSelectorShouldInitialise(ROUTE_A)
  })

  it('should initialise routeA function when no cookies present', function() {
    abTest(experimentDetails)

    expect(testResult).toBe(ROUTE_A);
  })

  it('should initialise routeA function when ab test cookie has no value', function() {
    whenCookieIsSetTo(NO_VALUE_AB_COOKIE).abTestSelectorShouldInitialise(ROUTE_A)
  })

  it('should initialise routeA function when ab test cookie has a corrupt value', function() {
    whenCookieIsSetTo(CORRUPT_COOKIE).abTestSelectorShouldInitialise(ROUTE_A)
  })
})