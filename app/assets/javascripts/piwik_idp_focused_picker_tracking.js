(function (global) {
    $(window).one('scroll', function() {
        _paq.push(['trackEvent', 'Engagement', 'Start page scroll', 'scrolled']);
    })
    
    $('summary').one('click', function() {
        _paq.push(['trackEvent', 'Engagement', 'Opened summary', 'clicked']);
    })

})(window);
