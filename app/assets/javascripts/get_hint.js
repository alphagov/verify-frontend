$(document).ready(function() {
    $.get({
        url: "https://www.signin.service.gov.uk/hint", 
        cache: false
      }).then(function(data){
        if(data.value){
            var verifyRadio = $("input[value=sign-in-with-gov-uk-verify]")
            var verifyContainer = verifyRadio.parent();
            verifyContainer.prev().insertAfter(verifyContainer);
        }
      });
});
