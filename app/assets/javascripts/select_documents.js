//= require jquery
//= require jquery.validate

(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var selectDocuments = {
    markAllAsNo: function() {
      // Mark all documents as 'No' when "I don't have documents" is selected
      var $checkbox = $(this);
      var checkboxValue = $checkbox.val();
      var $noAnswers = selectDocuments.$form.find('input[type=radio][value=false]');

      if (checkboxValue === "true") {
        $noAnswers.trigger('click');
      }
    },
    unCheckNoDocuments: function() {
      // Un check "I don't have documents" if the user selects a document
      var $checkbox = selectDocuments.$form.find('.js-no-docs:checked');
      $checkbox.prop('checked',false);
      $checkbox.parent('.block-label').removeClass('selected');
    },
    init: function (){
      selectDocuments.$form = $('#validate-documents');
      if (selectDocuments.$form.length === 1) {
        selectDocuments.$form.find('.js-no-docs').on('click',selectDocuments.markAllAsNo);
        selectDocuments.$form.find('input[type=radio][value=true]').on('click',selectDocuments.unCheckNoDocuments);

        $.validator.addMethod('selectDocumentsValidation', function(value, element) {
          var valid = true;
          var noSelections = function() {
            return selectDocuments.$form.find('input').filter(':checked').length === 0;
          };
          var insufficientSelectionsThatImplyNoEvidence = function() {
            var checkedElements = selectDocuments.$form.find('input').filter(':checked');
            return (checkedElements.length === 1 && checkedElements.val() === 'false');
          };
          if (noSelections() || insufficientSelectionsThatImplyNoEvidence()) {
            valid = false;
          }
          return valid;
        }, $.validator.format('Please select the documents you have'));
        selectDocuments.$form.validate({
          rules: {
            'select_documents_form[uk_driving_licence]': 'selectDocumentsValidation',
            'select_documents_form[uk_passport]': 'selectDocumentsValidation',
            'select_documents_form[foreign_id]': 'selectDocumentsValidation',
            'select_documents_form[no_docs]': 'selectDocumentsValidation'
          },
          groups: {
            // driving_licence is the first element, error should focus this
            driving_licence: 'select_documents_form[uk_driving_licence] select_documents_form[uk_passport] select_documents_form[foreign_id] select_documents_form[no_docs]'
          },
          highlight: function(element, errorClass) {
            selectDocuments.$form.children('.form-group:first').addClass('error');
          },
          unhighlight: function(element, errorClass) {
            selectDocuments.$form.children('.form-group:first').removeClass('error');
          }
        });

      }
    }
  };

  root.GOVUK.selectDocuments = selectDocuments;
}).call(this);
