# encoding: UTF-8
# frozen_string_literal: true
require_relative 'paths'
module Rubyongo
  #module VERSION
  #  MAJOR = 0
  #  MINOR = 1
  #  TINY  = 0
  #  PRE   = "alpha"
  #
  #  STRING = [MAJOR, MINOR, TINY, PRE].compact.join(".")
  #end

  def self.version
    File.read(File.join(Rubyongo::GEM_PATH, 'ROG_VERSION'))
    #Rubyongo::VERSION::STRING
  end
end