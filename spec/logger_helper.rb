def stub_logger
  logger = double(:logger)
  rails_double = double(:rails, logger: logger)
  stub_const("Rails", rails_double)
  logger
end
