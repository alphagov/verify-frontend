
describe('AB Test Selector', function () {

  var VARIANT_COOKIE = "ab_test=%7B%22app_transparency%22%3A%22app_transparency_variant%22%7D";
  var CONTROL_COOKIE = "ab_test=%7B%22app_transparency%22%3A%22app_transparency_control%22%7D";
  var UNRELATED_COOKIE = "random_cookie=%7B%22app_transparency%22%3A%22app_transparency_control%22%7D";
  var NO_VALUE_AB_COOKIE = "ab_test=";
  var CORRUPT_COOKIE = "ab_test=%22app_transparency%22%3A%22app_transparency_variant%22%7D";

  var ROUTE_A = 'route_a'
  var ROUTE_B = 'route_b'
  var testResult = '';

  var routeA = {
    init: function (){
      testResult = ROUTE_A
    }
  };

  var routeB = {
    init: function (){
      testResult = ROUTE_B
    }
  };

  beforeEach(function () {
    document.cookie.split(";").forEach(function(c) { document.cookie = c.replace(/^ +/, "").replace(/=.*/, "=;expires=" + new Date().toUTCString() + ";path=/"); });

    testResult = ''
  });

  it('should initialise routeB function when ab test cookie is variant', function() {
    document.cookie = VARIANT_COOKIE;

    abTest({
      experiment: 'app_transparency',
      routeA: routeA,
      routeB: routeB
    })

    expect(testResult).toBe(ROUTE_B);
  })


  it('should initialise routeA function when ab test cookie is control', function() {
    document.cookie = CONTROL_COOKIE;

    abTest({
      experiment: 'app_transparency',
      routeA: routeA,
      routeB: routeB
    })

    expect(testResult).toBe(ROUTE_A);
  })

  it('should initialise routeA function when ab test cookie is not present', function() {
    document.cookie = UNRELATED_COOKIE;

    abTest({
      experiment: 'app_transparency',
      routeA: routeA,
      routeB: routeB
    })

    expect(testResult).toBe(ROUTE_A);
  })

  it('should initialise routeA function when no cookies present', function() {
    abTest({
      experiment: 'app_transparency',
      routeA: routeA,
      routeB: routeB
    })

    expect(testResult).toBe(ROUTE_A);
  })

  it('should initialise routeA function when ab test cookie has no value', function() {
    document.cookie = NO_VALUE_AB_COOKIE;

    abTest({
      experiment: 'app_transparency',
      routeA: routeA,
      routeB: routeB
    })

    expect(testResult).toBe(ROUTE_A);
  })

  it('should initialise routeA function when ab test cookie has a corrupt value', function() {
    document.cookie = CORRUPT_COOKIE;

    abTest({
      experiment: 'app_transparency',
      routeA: routeA,
      routeB: routeB
    })

    expect(testResult).toBe(ROUTE_A);
  })
})