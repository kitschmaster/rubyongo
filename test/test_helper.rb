$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'yaml'
require 'minitest/autorun'
require "capybara"
require "capybara/dsl"
require 'rack/test'
require 'rubyongo'
require 'rubyongo/panel/test'
require 'selenium-webdriver'

#Capybara.default_driver = :selenium


require 'capybara'
require 'capybara/dsl'
#Capybara.app = Rubyongo::Kit
Capybara.app = Rack::Builder.parse_file(File.expand_path('../../config.ru', __FILE__)).first

# Unfortunately this is required to get it running, FF 48 works, but not the latest one.
Selenium::WebDriver::Firefox::Binary.path="/Users/mihael/opensource/Firefox.app/Contents/MacOS/firefox-bin"

Capybara.server_host = '0.0.0.0'
Capybara.server_port = 9393
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => 'firefox'.to_sym)
end
Capybara.default_driver = :selenium
