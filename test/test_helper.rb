# Set environment to test
ENV['RACK_ENV'] = 'test'

# Use a test config file
ENV['PANEL_TEST_CONFIG_FILE'] = File.expand_path('../panel_test.yml', __FILE__)

# Recreate the test db every time
FileUtils.rm_rf('test-db.sqlite') if File.exist?('test-db.sqlite')

# Load and require
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'yaml'
require 'minitest/autorun'
require 'minitest/capybara'
require 'rack/test'
require "capybara"
require "capybara/dsl"
require 'capybara/poltergeist'
require 'spec_helpers'
require 'test_helpers'
require 'rubyongo'
require 'rubyongo/panel/test'

# Add spec helpers
module Rubyongo
  class Spec <  Minitest::Capybara::Spec
    include SpecHelpers
  end
end

# Add test helpers
module Rubyongo
   class Test < Minitest::Test
    include TestHelpers
  end
end


# Set the driver
Capybara.default_driver = :poltergeist

# Set the Capybara app
Capybara.app = Rubyongo::Kit

