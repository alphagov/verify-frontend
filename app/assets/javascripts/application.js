//= require vendor/polyfills/bind
//= require elements/vendor/details.polyfill
//= require jquery
//= require jquery_ujs
//= require jquery.validate
//= require govuk/selection-buttons
//= require_tree .
//= require piwik

window.GOVUK.validation.init();
window.GOVUK.selectDocuments.init();
window.GOVUK.selectPhone.init();
window.GOVUK.willItWorkForMe.init();
window.GOVUK.chooseACertifiedCompany.init();

$(function () {
  // Use GOV.UK selection-buttons.js to set selected and focused states for block labels
  var $blockLabelInput = $(".block-label").find("input[type='radio'],input[type='checkbox']");
  new GOVUK.SelectionButtons($blockLabelInput);

  window.GOVUK.validation.attach();
  window.GOVUK.signin.attach();
});
