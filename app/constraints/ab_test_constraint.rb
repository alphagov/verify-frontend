module AbTestConstraint
  mattr_accessor :experiment_name, :experiment_loa, :trial_enabled
  def self.configure(ab_test_name: experiment_name, experiment_loa: loa, trial_enabled: false)
    self.experiment_name = ab_test_name
    self.experiment_loa = experiment_loa
    self.trial_enabled = trial_enabled
    self
  end

  def self.use(alternative:)
    SelectRoute.new(experiment_name, alternative, experiment_loa: experiment_loa, trial_enabled: trial_enabled)
  end
end
