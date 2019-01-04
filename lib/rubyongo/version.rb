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

  # Gem version
  def self.version
    File.read(File.join(Rubyongo::GEM_PATH, 'ROG_VERSION'))
    #Rubyongo::VERSION::STRING
  end

  # Framework user's current version
  def self.version_for(rog_dir)
    File.read(File.join(rog_dir, 'VERSION'))
  end

  # Write the framework user's version during >rog new< and >rog upgrade<
  def self.write_version_for(rog_dir, version)
    File.write(File.join(rog_dir, 'VERSION'), version)
  end
end