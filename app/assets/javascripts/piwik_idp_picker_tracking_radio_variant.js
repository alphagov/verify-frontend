(function (global) {
    var allRadioButtons = $('#choose-a-certified-company-form .multiple-choice'); // for radio RadioButtons, we're checking the input tags
    var numberOfVisibleRadioButtons = 0;

    var isVisible = function(element) {
        viewportHeight = $(window).height();
        elementPosition = element.getBoundingClientRect().top + element.getBoundingClientRect().height/2;
        return viewportHeight > elementPosition;
    };

    var canSeeAllRadioButtons = function() {
        return numberOfVisibleRadioButtons === allRadioButtons.length
    }

    allRadioButtons.each(function() {
        if(isVisible(this)) {
            numberOfVisibleRadioButtons++;
        };
    });

    if(canSeeAllRadioButtons()){
        var eventAction = 'All';
    }
    else if (numberOfVisibleRadioButtons === 0) {
        var eventAction = 'None';
    } 
    else {
        var eventAction = numberOfVisibleRadioButtons.toString();
    }

    _paq.push(['trackEvent', 'Engagement', eventAction, 'IDP visibility']);

    $(window).one('scroll', function() {
        _paq.push(['trackEvent', 'Engagement', 'Picker scroll', 'scrolled']);
    })

    var alreadySelected = false;
    $('#choose-a-certified-company-form input[name=entity_id]').on('change', function(event) { 
        if(alreadySelected){
            _paq.push(['trackEvent', 'Engagement', 'IDP changed', event.currentTarget.dataset.name]);
        }
        else {
            _paq.push(['trackEvent', 'Engagement', 'IDP selected', event.currentTarget.dataset.name]);
            alreadySelected = true;
        }
        event.stopImmediatePropagation();
    });

})(window);

