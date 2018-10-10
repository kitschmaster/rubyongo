# encoding: UTF-8
# frozen_string_literal: true
class String
  # Extracting frontmatter
  # Gets a substring from self delimited with between
  def extract between
    self[/#{Regexp.escape(between)}(.*?)#{Regexp.escape(between)}/m, 1]
  end
end

module Rubyongo

  class Archetyper

    TOML_MARKER = '+++'
    YAML_MARKER = '---'

    def self.archetypes(root_path = Rubyongo::EXEC_PATH)
      Archetyper.archetypes_paths(root_path).map {|archetype_path| Archetyper.file_entries(archetype_path)}.flatten.uniq
    end

    def self.archetypes_paths_for(root_path, theme)
      paths = [File.join(root_path, 'themes', theme || Rubyongo::DEFAULT_THEME, 'archetypes')]
      frusers_archetypes = File.join(root_path, 'archetypes') # framework users archetypes live in the root of a Hugo site
      paths << frusers_archetypes if File.directory?(frusers_archetypes)
      paths
    end

    def self.archetypes_paths(root_path = Rubyongo::EXEC_PATH, theme = Rubyongo::DEFAULT_THEME)
      Archetyper.archetypes_paths_for(root_path, theme)
    end

    def self.create_content_structure(root_path)
      Archetyper.archetypes(root_path).each do |archetype|
        content_archetype_dir = File.join(root_path, 'content', archetype)
        Dir.mkdir(content_archetype_dir) unless File.exists?(content_archetype_dir)
      end
    end

    # TODO
    def self.params_for(archetype)
      # get archetype path
      archetype_file = archetype_file(archetype)

      # read file in format and parse
      params = read_archetype(archetype_file)

      # return hash
      #{'default' => archetype_file}
      params
    end

    private

      def self.file_entries(path)
        fe = Dir.entries(path).select {|entry| !File.directory?(File.join(path, entry)) && !(entry =='.' || entry == '..' || entry == 'default.md') }
        fe.collect{|e| File.basename(e, '.md')}
      end


      # take an archetype file and read the frontmatter into a Hash
      # TODO: extract frontmatter first
      def self.read_archetype(file)
        # read first line and determine frontmatter format, is it JSON, YAML or TOML? or maybe org mode?
        first_line = File.open(file) {|f| f.readline}
        case first_line.strip
        when TOML_MARKER
          frontmatter = File.read(file).to_s.extract(TOML_MARKER) # extract frontmatter here
          puts "extracted #{frontmatter}"
          TomlRB.parse frontmatter
        when '---' # YAML
          YAML.load(file)
        when '{'   # JSON
          JSON.load(file)
        when '#'   # org mode
          raise "org mode frontmatter is not yet supported."
        else
          raise "#{file} does not contain valid frontmatter."
        end
      end
  end
end