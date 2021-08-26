require "rails_helper"
require "spec_helper"

describe AbTestConstraint do
  let(:ab_test_constraint) { AbTestConstraint.configure(ab_test_name: "Experiment", experiment_loa: LevelOfAssurance::LOA2) }
  it "returns new the ab_test constraint" do
    expect(ab_test_constraint).to eql subject
  end
  context "Experiment" do
    it "can create an alternative with a given value" do
      selected_route = ab_test_constraint.use(alternative: "one")
      expect(selected_route.class).to eql SelectRoute
      expect(selected_route.experiment_name).to eql "Experiment"
      expect(selected_route.experiment_loa).to eql LevelOfAssurance::LOA2
    end
  end
end
