# encoding: UTF-8
# frozen_string_literal: true

require_relative 'rubyongo/env'
require_relative 'rubyongo/paths'
require_relative 'rubyongo/version'
require_relative 'rubyongo/archetyper'

# Load Guru lib files
Dir.glob(Rubyongo::GURU_LIB, &method(:require))

# Load Panel UI backend sinatra app
require "rubyongo/panel/kit"

module Sinatra
  module Reloader
    # Monkey patch Reloader.perform to be able to reload framework user's code
    def self.perform(klass)
      Watcher::List.for(klass).updated.each do |watcher|
        klass.set(:inline_templates, watcher.path) if watcher.inline_templates?
        watcher.elements.each { |element| klass.deactivate(element) }
        $LOADED_FEATURES.delete(watcher.path)
        if watcher.path =~ /#{Rubyongo::PANEL_LIB_MATCH}/
          Rubyongo::Kit.load_panel_lib
        else
          require watcher.path
        end
        watcher.update
      end
      @@after_reload.each(&:call) if defined?(@@after_reload)
    end
  end
end

module Rubyongo
  class Kit < Sinatra::Base
    # The framework user should be able to write classic style Sinatra dsl.
    # To do that, the code needs to be evaluated in the context of the Kit class.
    def self.load_panel_lib
      Dir.glob(Rubyongo::PANEL_LIB).each do |file|
        code = File.read(file)
        instance_eval code.dup.taint, file if code
      end
    end

    # Load framework user's Panel code.
    load_panel_lib
  end
end