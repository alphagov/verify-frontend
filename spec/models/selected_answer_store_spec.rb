require "spec_helper"
require "models/selected_answer_store"

RSpec.describe SelectedAnswerStore do
  it "should store answers for a given stage" do
    session = {}
    document_answers = {
      passport: true,
      driving_licence: false,
    }
    store = SelectedAnswerStore.new(session)
    store.store_selected_answers(:documents, document_answers)
    expect(session[:selected_answers]).to eql(documents: document_answers)
    expect(store.selected_answers).to eql(documents: document_answers)
  end

  it "should return selected evidence for a given stage" do
    session = {}
    document_answers = {
      passport: true,
      driving_licence: false,
    }
    store = SelectedAnswerStore.new(session)
    store.store_selected_answers(:documents, document_answers)
    expect(store.selected_evidence_for(:documents)).to eql [:passport]
  end

  it "should return all selected evidence" do
    session = {}
    document_answers = {
      passport: true,
      driving_licence: false,
    }
    phone_answers = {
      mobile_phone: true,
    }
    store = SelectedAnswerStore.new(session)
    store.store_selected_answers(:documents, document_answers)
    store.store_selected_answers(:phone, phone_answers)
    expect(store.selected_evidence).to eql %i[passport mobile_phone]
  end

  it "should overwrite stale answers with new ones" do
    session = {}
    old_answers = {
        passport: true,
        driving_licence: false,
    }
    new_answers = {
        non_uk_id_document: true,
    }

    store = SelectedAnswerStore.new(session)
    store.store_selected_answers(:documents, old_answers)
    store.store_selected_answers(:documents, new_answers)

    expect(session[:selected_answers]).to eql(documents: new_answers)
    expect(store.selected_answers).to eql(documents: new_answers)
  end
end
