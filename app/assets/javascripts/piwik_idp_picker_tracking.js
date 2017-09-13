(function (global) {
    var allButtons = $('#matching-idps button.button');
    var numberOfVisibleButtons = 0;

    var isVisible = function(element) {
        viewportHeight = $(window).height();
        elementPosition = element.getBoundingClientRect().top + element.getBoundingClientRect().height/2;
        return viewportHeight > elementPosition;
    };

    allButtons.each(function(){
        if(isVisible(this)){
            numberOfVisibleButtons++;
        };
    });

    var eventName = allButtons.length === numberOfVisibleButtons ? 'All' : 'Some';

    _paq.push(['trackEvent', 'Engagement', 'IDP visibility', eventName, numberOfVisibleButtons]);


    $(window).scroll(function() {
        _paq.push(['trackEvent', 'Engagement', 'Picker scroll', 'scrolled' ]);
        $(window).off('scroll');
    })
    
})(window);

