# encoding: UTF-8
# frozen_string_literal: true
require 'open3'

class String
  # Extracting frontmatter
  # Gets a substring from self delimited with between
  def extract between
    self[/#{Regexp.escape(between)}(.*?)#{Regexp.escape(between)}/m, 1]
  end

  # Colors
  # Print strings in the console with style
  def red; colorize(self, "\e[1m\e[31m"); end
  def green; colorize(self, "\e[1m\e[32m"); end
  def dark_green; colorize(self, "\e[32m"); end
  def yellow; colorize(self, "\e[1m\e[33m"); end
  def blue; colorize(self, "\e[1m\e[34m"); end
  def dark_blue; colorize(self, "\e[34m"); end
  def pur; colorize(self, "\e[1m\e[35m"); end
  def colorize(text, color_code) "#{color_code}#{text}\e[0m" end
  def say(with_color = :blue); puts "#{self.send(with_color.to_sym)}"; end
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

    def self.enable_theme_archetypes(root_path)
      default_archetype = File.join(root_path, 'archetypes', 'default.md')
      FileUtils.rm_rf(default_archetype)
    end

    def self.create_with_image(root_path = Rubyongo::EXEC_PATH, archetype, image)
      imagefile = image[0]
      thumbfile = image[1]
      contentfile_name = File.basename(imagefile).split('.').first + ".md"
      contentfile_path = File.join(archetype, contentfile_name)

      success = Archetyper.run_silent_cmd("cd #{root_path}; hugo new #{contentfile_path}")

      if success
        # Open the generated file and add image paths
        contentfile = File.join(root_path, 'content', contentfile_path)
        content = File.read(contentfile)

        # Add frontmatter
        replacements = {'image: ""' => %(image: "#{imagefile}"), 'thumb: ""' => %(thumb: "#{thumbfile}")}
        replacements.each {|k, v| content.gsub!(/#{k}/, "#{v}")}

        # Add content
        content << "\n#{Archetyper.image_tag(imagefile)}\n"

        File.open(contentfile, 'w') {|f| f.write content }
      end
    end

    def self.upload_filename(path = Rubyongo::CONTENT_PATH, filename='')
      File.join(path, filename)
    end

    def self.stream_filename(archetype, filename='')
      filename = (archetype.empty? || archetype == 'nothing') ? filename : File.join(archetype.downcase, filename)
      File.join(Rubyongo::CONTENT_PATH, filename)
    end

    def self.thumbnail_filename(filename='')
      filename.gsub(/\./, "-thumb.")
    end

    def self.make_thumbnail(path, resize, thumbnail_path)
      `convert #{path} -resize #{resize} #{thumbnail_path}`
    end

    def self.stream_in(archetype, filename, tempfile, resize='250x250')
      img = Archetyper.stream_filename(archetype, filename)
      thumb = Archetyper.thumbnail_filename(filename)
      img_thumbnail_path = Archetyper.stream_filename(archetype, thumb)
      File.open(img, 'wb') do |f|
        f.write(tempfile.read)
      end
      Archetyper.make_thumbnail(img, resize, img_thumbnail_path)

      relative_img = File.join( archetype, File.basename(img))
      relative_img_thumb = File.join(archetype, File.basename(thumb))
      image = [relative_img, relative_img_thumb]
      Archetyper.create_with_image(Rubyongo::EXEC_PATH, archetype, image)
      image
    end

    def self.upload(path, filename, tempfile, resize='250x250')
      img = Archetyper.upload_filename(path, filename)
      thmb = thumbnail_filename(filename)
      img_thumbnail_path = Archetyper.upload_filename(path, thmb)
      File.open(img, 'wb') do |f|
        f.write(tempfile.read)
      end
      Archetyper.make_thumbnail(img, resize, img_thumbnail_path)
      [img, img_thumbnail_path]
    end

    def self.save_content(path, content)
      File.open(path, 'w+') {|f| f.write(content) }
    end

    def self.friendly_filename(filename)
      #filename.gsub(/[^a-z0-9\-_ \.]+/, '_')
      filename
    end

    # Run some shell command, print success message in green, on fail print error in red
    def self.run_cmd(command, success_message)
      "\nRunning: #{command}".say(:green)
      r = "".dup
      exit_status = nil
      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        r << stdout.read
        exit_status = wait_thr.value # Process::Status object returned.
      end
      puts r # TODO: can be made optional for a verbose run
      if exit_status.success?
        "#{success_message}".say(:green)
      else
        r.say(:red)
      end
    end

    # Run some shell command silently
    def self.run_silent_cmd(command)
      r = `#{command}`
      if r =~ //
        true
      else
        false
      end
    end

    def self.image_tag(path)
      return '' unless File.exist?(path)
      p = path
      if path =~ /\A\.\/content/
        p = path.gsub(/\.\/content/, '')
      elsif path =~ /\A\.\/themes/
        p = File.join( path.gsub(/\.\/themes/, '').split('/')[2..-1] )
      end
      p = File.join('/', p) unless p =~ /\A\//
      %(![#{File.basename(p)}](#{p}))
    end

    def self.inline_image_tag(path)
      return '' unless File.exist?(path)
      %(<img src="data:#{Archetyper.mimetype(path)};base64,#{Base64.encode64(File.read(path))}"/>)
    end

    def self.mimetype(path)
      `file -Ib #{path}`.gsub(/\n/,"")
    end

    # Data for jstree (which is used in the Panel to list and work with files)
    # See more at https://github.com/vakata/jstree
    def self.directory_hash(path, name=nil, excludes = [])
      excludes.concat(['..', '.', '.git', '__MACOSX', '.DS_Store'])
      data = {'text' => (name || path), 'id' => path}
      data[:children] = children = []
      Dir.foreach(path) do |entry|
        next if excludes.include?(entry)
        full_path = File.join(path, entry)
        if File.directory?(full_path)
          children << Archetyper.directory_hash(full_path, entry) # recursive call here!
        else
          children << {'icon' => 'jstree-file', 'text' => entry, 'id' => full_path, 'type' => 'file'}
        end
      end
      return data
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