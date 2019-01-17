ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'test_helpers'
require 'rubyongo'
require 'rubyongo/panel/test'

# Add test helpers
module Rubyongo
   class Test < Minitest::Test
    include TestHelpers
  end
end