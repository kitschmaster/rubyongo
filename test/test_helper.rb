ENV['RACK_ENV']='test'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'yaml'
require 'minitest/autorun'
require 'minitest/capybara'
require 'rack/test'
require "capybara"
require "capybara/dsl"
require 'capybara/poltergeist'
require 'rubyongo'
require 'rubyongo/panel/test'
require 'spec_helpers'
module Rubyongo
  class Spec
    include SpecHelpers
  end
end

Capybara.default_driver = :poltergeist
Capybara.app = Rubyongo::Kit

