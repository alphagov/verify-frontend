(function (global) {
    var allButtons = $('#matching-idps button.button');
    var numberOfVisibleButtons = 0;

    var isVisible = function(element) {
        viewportHeight = $(window).height();
        elementPosition = element.getBoundingClientRect().top + element.getBoundingClientRect().height/2;
        return viewportHeight > elementPosition;
    };

    var canSeeAllButtons = function() {
        return numberOfVisibleButtons === allButtons.length
    }

    allButtons.each(function() {
        if(isVisible(this)) {
            numberOfVisibleButtons++;
        };
    });

    var eventAction = canSeeAllButtons() ? 'All' : numberOfVisibleButtons.toString();

    _paq.push(['trackEvent', 'Engagement', eventAction, 'IDP visibility']);


    $(window).scroll(function() {
        _paq.push(['trackEvent', 'Engagement', 'Picker scroll', 'scrolled']);
        $(window).off('scroll');
    })

})(window);

