$(document).ready(function() {
    $.ajax({
        url: 'https://www.signin.service.gov.uk/hint', 
        cache: false,
        dataType: 'jsonp'
      }).then(function(data){
        if(data.value){
          var verifyRadio = $('input[value=sign-in-with-gov-uk-verify]');
          var verifyContainer = verifyRadio.parent();
          verifyContainer.prev().insertAfter(verifyContainer);
          GOVUK.analytics.trackEvent('verify-hint', 'shown', { transport: 'beacon' })

          $('*[data-module="track-radio-group"]').on('submit', function (event) {
            var options = { transport: 'beacon' };
    
            var $submittedForm = $(event.target);
    
            var $checkedOption = $submittedForm.find('input:checked');
    
            var checkedValue = $checkedOption.val();
    
            if (typeof checkedValue === 'undefined') {
              checkedValue = 'submitted-without-choosing';
            }
    
            GOVUK.analytics.trackEvent('Radio button chosen', checkedValue + '-with-hint', options);
          });
        }
      });
});
