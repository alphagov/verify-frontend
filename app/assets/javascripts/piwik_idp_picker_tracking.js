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

    if(canSeeAllButtons()){
        var eventAction = 'All';
    }
    else if (numberOfVisibleButtons === 0) {
        var eventAction = 'None';
    } 
    else {
        var eventAction = numberOfVisibleButtons.toString();
    }

    _paq.push(['trackEvent', 'Engagement', eventAction, 'IDP visibility']);

    $(window).one('scroll', function() {
        _paq.push(['trackEvent', 'Engagement', 'Picker scroll', 'scrolled']);
    })

    $('button').on('click', function(e) {
        if (e.which === 1) {
            var buttonOrder = parseInt($(e.target).data('order'))
            _paq.push(['trackEvent', 'Engagement', buttonOrder, 'IDP order click']);
        }
        
    })

})(window);

