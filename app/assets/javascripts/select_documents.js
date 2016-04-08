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
          var numberOfDocumentQuestions = 3;
          var checkedElements = selectDocuments.$form.find('input[type=radio]').filter(':checked');
          var allDocumentQuestionsAnswered = checkedElements.length === numberOfDocumentQuestions;
          var hasAtLeastOneDocument = checkedElements.filter('[value=true]').length > 0;
          return allDocumentQuestionsAnswered || hasAtLeastOneDocument;
        }, $.validator.format(selectDocuments.$form.data('msg')));

        selectDocuments.$form.validate({
          rules: {
            'select_documents_form[driving_licence]': 'selectDocumentsValidation',
            'select_documents_form[passport]': 'selectDocumentsValidation',
            'select_documents_form[non_uk_id_document]': 'selectDocumentsValidation',
            'select_documents_form[no_documents]': 'selectDocumentsValidation'
          },
          groups: {
            // driving_licence is the first element, error should focus this
            driving_licence: 'select_documents_form[driving_licence] select_documents_form[passport] select_documents_form[non_uk_id_document] select_documents_form[no_documents]'
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
