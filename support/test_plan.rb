require "pathname"

require_relative "../support/current_bundle"

class TestPlan
  PROJECT_DIRECTORY = Pathname.new("..").expand_path(__dir__)
  SUPPORT_DIR = PROJECT_DIRECTORY.join("spec/support")
  INSIDE_INTEGRATION_TEST = true

  def initialize(
    using_outside_of_zeus: false,
    color_enabled: false,
    configuration: {}
  )
    @using_outside_of_zeus = using_outside_of_zeus
    @color_enabled = color_enabled
    @configuration = configuration

    @pry_enabled = true
    @libraries = []
  end

  def after_fork
    reconnect_activerecord
  end

  def boot
    ENV["BUNDLE_GEMFILE"] ||=
      SuperDiff::CurrentBundle.instance.latest_appraisal.gemfile_path.to_s
    require "bundler/setup"

    $LOAD_PATH.unshift(PROJECT_DIRECTORY.join("lib"))

    begin
      require "pry-byebug"
    rescue LoadError
      require "pry-nav"
    end

    # Fix Zeus for 0.13.0+
    Pry::Pager.class_eval do
      def best_available
        Pry::Pager::NullPager.new(pry_instance.output)
      end
    end

    require "rspec"

    require "super_diff"
    SuperDiff.const_set(:IntegrationTests, Module.new)

    Dir.glob(SUPPORT_DIR.join("{models,matchers}/*.rb")).sort.each do |path|
      require path
    end

    require SUPPORT_DIR.join("integration/matchers")

    RSpec.configure do |config|
      config.include SuperDiff::IntegrationTests
    end
  end

  def boot_active_record
    require "active_record"

    ActiveRecord::Base.establish_connection(
      adapter: "sqlite3",
      database: ":memory:",
    )

    Dir.glob(SUPPORT_DIR.join("models/active_record/*.rb")).sort.each do |path|
      require path
    end
  rescue LoadError
    # active_record may not be in the Gemfile, so that's okay
  end

  def run_plain_test
    run_test("super_diff/rspec")
  end

  def run_rspec_active_record_test
    run_test("super_diff/rspec", "super_diff/active_record")
  end

  def run_rspec_rails_test
    run_test("super_diff/rspec-rails")
  end

  def confirm_started
    puts "Zeus server started!"
  end

  private

  attr_reader :libraries, :configuration

  def using_outside_of_zeus?
    @using_outside_of_zeus
  end

  def color_enabled?
    @color_enabled
  end

  def pry_enabled?
    @pry_enabled
  end

  def reconnect_activerecord
    return unless defined?(ActiveRecord::Base)

    begin
      ActiveRecord::Base.clear_all_connections!
      ActiveRecord::Base.establish_connection
      if ActiveRecord::Base.respond_to?(:shared_connection)
        ActiveRecord::Base.shared_connection =
          ActiveRecord::Base.retrieve_connection
      end
    rescue ActiveRecord::AdapterNotSpecified
    end
  end

  def run_test(*libraries)
    if !using_outside_of_zeus?
      option_parser.parse!
    end

    RSpec.configure do |config|
      config.color_mode = color_enabled? ? :on : :off
    end

    SuperDiff.configuration.merge!(
      configuration.merge(color_enabled: color_enabled?)
    )

    if !pry_enabled?
      ENV["DISABLE_PRY"] = "true"
    end

    yield if block_given?

    libraries.each do |library|
      require library
    end

    if !using_outside_of_zeus?
      RSpec::Core::Runner.invoke
    end
  end

  def option_parser
    @_option_parser ||= OptionParser.new do |opts|
      opts.on("--[no-]color", "Enable or disable color.") do |value|
        @color_enabled = value
      end

      opts.on("--[no-]pry", "Disable Pry.") do |value|
        @pry_enabled = value
      end

      opts.on("--configuration CONFIG", String, "Configure SuperDiff.") do |json|
        @configuration = JSON.parse(json).transform_keys(&:to_sym)
      end
    end
  end
end
