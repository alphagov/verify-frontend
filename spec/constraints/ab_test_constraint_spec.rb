require "rails_helper"
require "spec_helper"

describe AbTestConstraint do
  let(:ab_test_constraint) { AbTestConstraint.configure(ab_test_name: "Experiment", experiment_loa: "LEVEL_2") }
  it "returns new the ab_test constraint" do
    expect(ab_test_constraint).to eql subject
  end
  context "Experiment" do
    it "uses alternative a to produce Experiment route" do
      selected_route = ab_test_constraint.use(alternative: "one")
      expect(selected_route.class).to eql SelectRoute
      expect(selected_route.experiment_name).to eql "Experiment"
      expect(selected_route.experiment_loa).to eql "LEVEL_2"
    end
  end
end
