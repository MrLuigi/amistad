require 'rspec'
require 'active_record'
require 'ap'
require 'database_cleaner'
Dir["#{File.dirname(__FILE__)}/support/*.rb"].each {|f| require f}


def create_users( friend_model )
  friend_model.delete_all
  %w(John Jane David James Peter Mary Victoria Elisabeth Lonely).each do |name|
    instance_variable_set(
      "@#{name.downcase}".to_sym,
      friend_model.create{ |fm| fm.name = name }
    )
  end
end


def activate_amistad( friend_model )
  friend_model.class_exec do
    include Amistad::FriendModel
  end
end


def reload_environment
  # ensure that the gem will be always required
  $".grep(/.*lib\/amistad.*/).each do |file|
    $".delete(file)
  end

  # delete all the classes
  if Object.const_defined?(:Amistad)
    Amistad.constants.each do |constant|
      Amistad.send(:remove_const, constant)
    end

    Object.send(:remove_const, :Amistad)
  end

  Object.send(:remove_const, :User) if Object.const_defined?(:User)
  Object.send(:remove_const, :Profile) if Object.const_defined?(:Profile)

  # require the gem
  require "amistad"
end


RSpec.configure do |config|
  # [Steve A., 20151014] Use a Ruby 1.9.2-compliant syntax for the pattern matchers:
  # (Current default uses a Ruby 2+ syntax)
#  config.pattern = "**/*_spec.rb"

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.

  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
#  config.filter_run :focus
#  config.run_all_when_everything_filtered = true

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
#  config.disable_monkey_patching!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
end
