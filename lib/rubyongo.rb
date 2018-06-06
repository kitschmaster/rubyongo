# encoding: UTF-8
# frozen_string_literal: true

require_relative 'rubyongo/paths'
require_relative 'rubyongo/version'

# Load Guru lib files
Dir.glob(Rubyongo::GURU_LIB, &method(:require))

# Load Panel UI backend sinatra app
require "rubyongo/panel/kit"

# Load framework user's Panel overrides and libs. The framework user should be able to rewrite the Panel at wish.
Dir.glob(Rubyongo::PANEL_LIB, &method(:require))
