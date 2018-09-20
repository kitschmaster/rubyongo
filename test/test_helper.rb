$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'yaml'
require 'minitest/autorun'
require "capybara"
require "capybara/dsl"
require 'rack/test'
require 'rubyongo'
require 'rubyongo/panel/test'
require 'selenium-webdriver'

require 'capybara'
require 'capybara/dsl'

# Unfortunately this is required to get js tests running, FF 48 works, but not the latest one.
begin
  Selenium::WebDriver::Firefox::Binary.path= File.expand_path "~/opensource/Firefox.app/Contents/MacOS/firefox-bin"
rescue
end

Capybara.app = Rubyongo::Kit
Capybara.server_host = '0.0.0.0'
Capybara.server_port = 9393
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end
Capybara.default_driver = :selenium
