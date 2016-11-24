$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'pp'
require 'simplecov'

SimpleCov.start

require 'ceres'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.backtrace_exclusion_patterns << /sun\.reflect/
  config.backtrace_exclusion_patterns << /org\.jruby/

  config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed
end
