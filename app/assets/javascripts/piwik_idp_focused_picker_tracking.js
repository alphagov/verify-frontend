(function (global) {
    var greenButton = $('#begin-registration-path')[0];

    var isVisible = function(element) {
        viewportHeight = $(window).height();
        elementPosition = element.getBoundingClientRect().top + element.getBoundingClientRect().height/2;
        return viewportHeight > elementPosition;
    };

    if(isVisible(greenButton)){
        var eventAction = 'Yes';
    }
    else {
        var eventAction = 'No';
    }

    _paq.push(['trackEvent', 'Engagement', eventAction, 'Start page green button visibility']);

    $(window).one('scroll', function() {
        _paq.push(['trackEvent', 'Engagement', 'Start page scroll', 'scrolled']);
    })
    
    $('summary').one('click', function() {
        _paq.push(['trackEvent', 'Engagement', 'Opened summary', 'clicked']);
    })

})(window);
