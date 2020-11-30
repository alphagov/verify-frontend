require "rails_helper"
RSpec.describe SelectDocumentsForm, skip_before: true do
  context "is invalid" do
    it "has all check boxes empty" do
      form = SelectDocumentsForm.new({})
      expect(form).to_not be_valid
      expect(form.errors.full_messages.first).to include I18n.t("hub.select_documents.errors.no_selection")
    end
  end
  context "is valid" do
    it "has any check box i.e (has valid passport)" do
      form = SelectDocumentsForm.new(has_valid_passport: "true")
      expect(form).to be_valid
    end
    it "has any check box i.e (has nothing) selected" do
      form = SelectDocumentsForm.new(has_nothing: "true")
      expect(form).to be_valid
    end
    it "has any check box i.e (has nothing) unselected" do
      form = SelectDocumentsForm.new(has_nothing: "false")
      expect(form).to be_valid
    end
  end
end
