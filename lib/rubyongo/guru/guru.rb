# encoding: UTF-8
# frozen_string_literal: true
require 'dm-core'
require 'dm-migrations'
require 'dm-transactions'
require 'dm-serializer'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-types'

class String
  def present?
    self != nil && self.size > 0
  end
end

class NilClass
  def present?
    false
  end
end

module Rubyongo

  # Guru is the Panel Kit's backend.
  class Guru
    include DataMapper::Resource

    property :id, Serial, :key => true
    property :username, String, :length => 128
    property :password, BCryptHash
    property :content_changed_at, DateTime
    property :content_published_at, DateTime
    property :theme, String, :length => 128

    def authenticate(attempted_password)
      # The BCrypt class, which `self.password` is an instance of, has `==` defined to compare a
      # test plain text string to the encrypted string and converts `attempted_password` to a BCrypt
      # for the comparison.
      #
      # But don't take my word for it, check out the source: https://github.com/codahale/bcrypt-ruby/blob/master/lib/bcrypt/password.rb#L64-L67
      if self.password == attempted_password
        true
      else
        false
      end
    end

    def mark_content_published_now
      self.content_changed_at = nil
      self.content_published_at = DateTime.now
      #.strftime('%Y-%m-%d %H:%M:%S %Z')
      refresh_theme
      self.save
    end

    def mark_content_changed_now
      self.content_changed_at = DateTime.now
      #.strftime('%Y-%m-%d %H:%M:%S %Z')
      refresh_theme
      self.save
    end

    def content_published?
      if self.content_published_at && self.content_changed_at
        return self.content_published_at >= self.content_changed_at
      elsif self.content_published_at
        return true
      end
      return false
    end

    def publish_content
      x = `#{HUGO_RUN_PATH} 2>&1`
      if $?.success?
        mark_content_published_now
        true
      else
        {'error' => "Error running hugo publish: #{x} with command: #{HUGO_RUN_PATH}"}
      end
    end

    # ./themes/default/archetypes + ./archetypes
    def archetypes_paths
      Archetyper.archetypes_paths_for_theme(self.theme)
    end

    # list framework users archetypes, plus the theme ones
    def archetypes
      @archetypes = Archetyper.archetypes
    end

    def themes
      @themes ||= Guru.dir_entries(THEMES_PATH)
    end

    # Read from config.toml and update Guru
    # TODO: Imagine a better way to do this update while avoiding file reading.
    def refresh_theme
      self.theme = Guru.extract_theme(CONFIG_PATH)
    end

    # Create a Guru
    def self.create_guru(username, password)
      Guru.init_db
      if Guru.count == 0
        @user = Guru.create(:username => username, :theme => DEFAULT_THEME)
        @user.password = password
        @user.save
      end
    end

    # Create the default Guru
    def self.create_default_guru(settings = nil)
      panel_guru = 'guru'
      panel_pass = 'gro.guru!!!'
      if settings && settings.pas && settings.usr
        panel_guru = settings.usr
        panel_pass = settings.pas
      end
      create_guru(panel_guru, panel_pass)
    end

    # Validate config.toml, for now just check if themes are supported
    def valid_config?(content)
      content.each_line do |line|
        extracted_theme = Guru.extract_setting('theme', line)
        #puts "valid_config? |#{extracted_theme}| >#{themes.include?(extracted_theme)}<"
        return themes.include?(extracted_theme) if extracted_theme.present?
      end
    end

    def self.test
      369
    end

    def self.init_db
      # Setup Guru DB
      db_path = "sqlite://#{EXEC_PATH}/db.sqlite"
      if ENV['RACK_ENV'] == 'test'
        db_path = "sqlite://#{EXEC_PATH}/test-db.sqlite"
      end

      #puts "Setting up DB: #{db_path}"
      DataMapper.setup(:default, db_path)

      # Tell DataMapper the models are done being defined
      DataMapper.finalize

      # Update the database to match the properties of Guru
      DataMapper.auto_upgrade!
    end

    private

    def self.dir_entries(path)
      Dir.entries(path).select {|entry| File.directory?(File.join(path,entry)) && !(entry =='.' || entry == '..') }
    end

    def self.extract_theme(config_toml_file)
      File.foreach(config_toml_file).with_index do |line, _line_num|
        extracted_theme = extract_setting('theme', line)
        return extracted_theme if extracted_theme.present?
      end
    end

    def self.extract_setting(name, line)
      if line =~ /\A#{name} =/
        split_line = line.split '='
        return split_line.last.chomp.gsub(/\"/, '').strip
      end
    end

    def fixup_theme(theme)
      themes.include?(theme) ? theme : DEFAULT_THEME
    end
  end
end