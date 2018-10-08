# encoding: UTF-8
# frozen_string_literal: true

# Ruby 1.9 needs this to properly deal with non USASCII, like ščž...
Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

# Load libs.
require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/flash'
require 'sinatra/json'
require 'sinatra/reloader'
require 'pathname'
require 'base64'
require 'fileutils'
require 'warden'
require 'json'
require 'rack/contrib/try_static'
require 'sysrandom/securerandom' # Replace the userspace Ruby (OpenSSL) RNG with `/dev/urandom`

module Rubyongo

  # Redirect errors to a file during production run.
  if ENV['RACK_ENV'] == 'production'
    # TODO: add logrotation ansible task (sys)

    log = File.new("log/production.log", "a+") # TODO path
    #$stdout.reopen(log)
    $stderr.reopen(log)
  end

  # Setup Warden authentication
  Warden::Strategies.add(:password) do
    def valid?
      params['guru'] && params['guru']['username'] && params['guru']['password']
    end

    def authenticate!
      guru = Rubyongo::Guru.first(:username => params['guru']['username'])

      if guru.nil?
        throw(:warden, :message => "The username you entered does not exist.")
      elsif guru.authenticate(params['guru']['password'])
        success!(guru)
      else
        throw(:warden, :message => "The username and password combination ")
      end
    end
  end

  # Kit is the Panel UI's backend.
  # It's basically a Sinatra app.
  # App code can be easily added/overridden by the framework user inside the folder /panel.
  #
  # The Panel is your clay, use it as you dodo.
  #
  class Kit < Sinatra::Base
    #************************************************************************************************
    # Code reloading
    #************************************************************************************************
    configure :development do
      register Sinatra::Reloader
      also_reload Rubyongo::GURU_LIB
    end

    #************************************************************************************************
    # Settings and extensions
    #************************************************************************************************
    register Sinatra::Flash
    register Sinatra::ConfigFile
    if ENV['RACK_ENV'] == 'test'
      test_config = File.expand_path('../../../../test/panel_test.yml', __FILE__)
      puts "Loading test config: #{test_config}"
      config_file test_config
    else
      config_file Rubyongo::PANEL_CONFIG_PATH
    end
    set :bind, '0.0.0.0'
    set :port, 9393

    # Set Sinatra views path.
    # Supporting view overrides by the framework user here, see #find_template helper override.
    # User can add/override files in panel/views/*.erb
    set :views, [Rubyongo::PANEL_VIEWS_PATH, Rubyongo::VIEWS_PATH]

    # calls `/dev/urandom`
    # or an appropriate OS kernel alternative
    set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

    enable :sessions

    #************************************************************************************************
    # Two public folders (the library one is being served before PANEL_PUBLIC_PATH)
    #************************************************************************************************
    set :public_folder, Rubyongo::PANEL_PUBLIC_PATH
    use Rack::TryStatic, :root => Rubyongo::PANEL_LIB_PUBLIC_PATH, :urls => %w[/]

    #************************************************************************************************
    # Logging
    #************************************************************************************************
    use Rack::Logger
    helpers do
      def logger
        request.logger
      end

      # Wrapping default #find_template to allow multiple views locations.
      def find_template(views, name, engine, &block)
        views.each { |v| super(v, name, engine, &block) }
      end
    end

    #************************************************************************************************
    # Guru
    #************************************************************************************************
    Rubyongo::Guru.create_default_guru settings

    #************************************************************************************************
    # Panel authentication
    #************************************************************************************************

    use Warden::Manager do |config|
      # Tell Warden how to save our Guru info into a session.
      # Sessions can only take strings, not Ruby code, we'll store
      # the Guru's `id`
      config.serialize_into_session{|guru| guru.id }
      # Now tell Warden how to take what we've stored in the session
      # and get a Guru from that information.
      config.serialize_from_session{|id| Rubyongo::Guru.get(id) }

      config.scope_defaults :default,
        # "strategies" is an array of named methods with which to
        # attempt authentication. We have to define this later.
        :strategies => [:password],
        # The action is a route to send the guru to when
        # warden.authenticate! returns a false answer. We'll show
        # this route below.
        :action => 'auth/unauthenticated'
      # When a guru tries to log in and cannot, this specifies the
      # app to send the guru to.
      config.failure_app = self
    end

    Warden::Manager.before_failure do |env,opts|
      # Because authentication failure can happen on any request but
      # we handle it only under "post '/auth/unauthenticated'", we need
      # to change request to POST
      env['REQUEST_METHOD'] = 'POST'
      # And we need to do the following to work with  Rack::MethodOverride
      env.each do |key, value|
        env[key]['_method'] = 'post' if key == 'rack.request.form_hash'
      end
    end

    helpers do
      def current_guru
        env['warden'].user
      end

      def guru_tunedin?
        env['warden'].authenticated?
      end

      def tuningin?
        request.path == '/auth/in'
      end

      def menu_item(title, link_title, icon_class, action)
        klass = ""
        klass = "pure-menu-selected" if request.path =~/#{action}/
        %( <li class="menu-item pure-menu-item #{klass}"><a title="#{link_title}" class="pure-menu-link" href="/#{action}"><i class="fa #{icon_class}"></i> #{title}</a></li> )
      end

      def publish_button_class
        current_guru.content_published? ? "button-primary" : "button-warning"
      end

      def fill_result(result={}, options={})
        result['content_published_at'] = current_guru.content_published_at ? current_guru.content_published_at.strftime("%c") : ''
        result['content_changed_at'] = current_guru.content_changed_at ? current_guru.content_changed_at.strftime("%c") : ''
        result['content_published'] = current_guru.content_published?
        result['archetypes'] = current_guru.archetypes
        result['theme'] = current_guru.theme
        result.merge! options if options
      end

      def editor_init
        fill_result
      end
    end # helpers

    # TODO(research): should backend UI mounting point be editable?
    # Should all these routes be editable at all?
    get '/panel' do
      set_message "Welcome!"
      erb :index
    end

    get '/auth/in' do
      erb :login
    end

    post '/auth/in' do
      auth!
      flash[:success] = "Successfully tuned in"
      if session[:return_to].nil?
        redirect '/panel'
      else
        redirect session[:return_to]
      end
    end

    get '/auth/out' do
      env['warden'].raw_session.inspect
      env['warden'].logout
      flash[:success] = 'Successfully tuned out'
      redirect '/panel'
    end

    post '/auth/unauthenticated' do
      session[:return_to] = env['warden.options'][:attempted_path] if session[:return_to].nil?

      # Set the error and use a fallback if the message is not defined
      flash[:error] = env['warden.options'][:message] || "You must log in"
      redirect '/auth/in'
    end

    #************************************************************************************************
    # Panel content editor
    #************************************************************************************************

    get '/content_editor' do
      auth!
      erb :editor
    end

    get '/content_editor/data' do
      auth!
      @entries = []
      ['content', 'themes', 'public'].each do |name|
        path = "./#{name}"
        @entries << Guru.directory_hash(path, name) if File.directory? path
      end
      json @entries
    end

    post '/content_editor/create_node' do
      auth!
      log "create_node #{params[:id]}  #{params[:type]} #{params[:text]}"
      r = {}
      type = params[:type]
      new_basename = params[:text]
      friendly_basename = Guru.friendly_filename(new_basename)
      if new_basename!=friendly_basename
        fill_result r, 'error' => "Please use something like >#{friendly_basename}< for the filename."
      else
        path = params[:id]
        old_basename = File.basename(path)
        new_path = File.join(path, new_basename)
        current_archetype = path.split('/')[2] #the archetypes are the folders within 'content'
        log "new path #{new_path} #{current_archetype}\n"
        if new_basename =~ /\./ && type == 'file'
          if current_guru.archetypes.include?(current_archetype)
            #use hugo to generate file
            hugopath = new_path.gsub(/\.\/content\//, '') # remove './content/' prefix from new_path!
            x = `#{HUGO_RUN_PATH} new #{hugopath}`
            if x =~ /created/
              current_guru.mark_content_changed_now
            else
              fill_result r, 'error' => "Error running hugo: #{x} with command: #{HUGO_RUN_PATH} new #{hugopath}"
            end
          else
            FileUtils.touch new_path
            current_guru.mark_content_changed_now
          end
        elsif type == 'default'
          FileUtils::mkdir_p new_path
          current_guru.mark_content_changed_now
        end
        fill_result r, 'id' => new_path
      end
      json r
    end

    post '/content_editor/delete_node' do
      auth!
      log "delete_node #{params[:id]}"
      r = {}
      path = params[:id]
      if File.directory?(path) || File.exists?(path)
        FileUtils.rm_rf path
        current_guru.mark_content_changed_now
        fill_result r, 'status' => 'OK'
      else
        fill_result r, 'error' => 'File not found.'
      end
      json r
    end

    post '/content_editor/move_node' do
      auth!
      log "move_node #{params[:id]} #{params[:parent]}"
      r = {}
      path = params[:id]
      new_basename = File.basename(path)
      new_path = File.join(params[:parent], new_basename)
      if path == new_path
        fill_result r, 'error' => 'Can not move unto itself.'
      else
        FileUtils.mv path, new_path
        current_guru.mark_content_changed_now
        fill_result r, 'id' => new_path
      end
      json r
    end

    post '/content_editor/rename_node' do
      auth!
      log "rename_node #{params[:id]} #{params[:text]}"
      r = {}
      new_basename = params[:text]
      friendly_basename = Guru.friendly_filename(new_basename)
      if new_basename!=friendly_basename
        fill_result r, 'error' => "Please use something like >#{friendly_basename}< for the filename."
      else
        path = params[:id]
        old_basename = File.basename(path)
        if File.directory?(path)
          dirname = File.dirname(path)
          new_path = File.join(dirname, new_basename)
          if path == new_path
            fill_result r, 'error' => 'Can not rename into itself.'
          else
            FileUtils.mv path, new_path
            current_guru.mark_content_changed_now
            fill_result r, 'id' => new_path
          end
        elsif File.exists?(path)
          dirname = File.dirname(path)
          new_path = File.join(dirname, new_basename)
          if path == new_path
            fill_result r, 'error' => 'Can not rename into itself.'
          else
            File.rename path, new_path
            current_guru.mark_content_changed_now
            fill_result r, 'id' => new_path
          end
        else
          fill_result r, 'error' => 'Invalid filename.'
        end
      end
      json r
    end

    get '/content_editor/node' do
      auth!
      #log "node #{params[:ids]}"
      path = params[:ids]
      default_read_file = false
      r = {}
      if path =~ /:/
        paths = params[:ids].split(':')
        r = {'type' => 'multiple', 'content' => paths}
      elsif path == 'config'
        default_read_file = true
        path = CONFIG_PATH
        r = {'type' => 'toml', 'content' => 'default', 'id' => 'config'}
      elsif File.directory?(path)
        r = {'type' => 'folder', 'content' => path}
      elsif File.exist?(path)
        #log "outputting file #{path}"
        ext  = File.extname(path)[1..-1]
        r = {'type' => ext, 'content' => 'default', 'preview' => nil, 'id' => path}
        case ext
          when *TEXT_FILES
            default_read_file = true
          when *IMAGE_FILES
            r['content'] = image_tag(path)
            r['preview'] = inline_image_tag(path) #unless File.exist?(path.gsub(/content/, 'public'))
          else
            r['content'] = "File not recognized: #{path}"
        end
      else
        r = {'type' => 'undefined', 'content' => '', 'id' => path}
      end
      if default_read_file
        fill_result r, 'content' => File.read(path)
      end
      json r
    end

    post '/content_editor/node' do
      auth!
      path = params[:id]
      content = params[:content]
      default_write_file = false
      config_edit = false
      r = {}
      if path =~ /:/
        paths = params[:ids].split(':')
        r = {'type' => 'multiple', 'content' => paths}
      elsif path == 'config'
        config_edit = true
        default_write_file = true
        path = CONFIG_PATH
        r = {'type' => 'toml', 'content' => content, 'id' => 'config'}
      elsif File.directory?(path)
        r = {'type' => 'folder', 'content' => path}
      elsif File.exist?(path)
        #log "outputting file #{path}"
        ext  = File.extname(path)[1..-1]
        r = {'type' => ext, 'content' => content, 'preview' => nil, 'id' => path}
        case ext
          when *TEXT_FILES
            default_write_file = true
          when *IMAGE_FILES
            r['content'] = image_tag(path)
            r['preview'] = inline_image_tag(path) #unless File.exist?(path.gsub(/content/, 'public'))
          else
            r['content'] = "File not recognized: #{path}"
        end
      else
        r = {'type' => 'undefined', 'content' => '', 'id' => path}
      end

      if default_write_file
        save_content = false
        if config_edit
          if current_guru.valid_config?(content)
            save_content = true
          else
            # Do not save content, only notify
            r['error'] = 'Invalid theme or other invalid settings.'
          end
        else
          save_content = true
        end
        if save_content
          Guru.save_content(path, content)
          current_guru.mark_content_changed_now
        end
        fill_result r
      end
      json r
    end

    post '/content_editor/node_upload' do
      auth!

      path = params[:path]
      files = params[:files]

      uploads = {}
      files.each do |file|
        uploads[file[:filename]] = Guru.upload(path, file[:filename], file[:tempfile], settings.thumbnail_resize)
      end

      r = {}
      fill_result r, :content => uploads
      json r
    end

    #************************************************************************************************
    # Content publishing via hugo
    #************************************************************************************************

    post '/panel/transend' do
      auth!
      r = {}
      published = current_guru.publish_content
      if published == true
        fill_result r
        log "\npublish #{current_guru.content_published_at}\n"
      else
        fill_result r, published
      end
      json r
    end

    #************************************************************************************************
    # An image/youtube stream uploader/remover
    # TODO: Allow streaming archetypes instead
    #************************************************************************************************

    get '/stream_editor' do
      auth!
      erb :stream
    end

    post '/stream_editor/in' do
      auth!
      archetype = params[:archetype]
      r = Guru.stream_in(archetype, params[:file][:filename], params[:file][:tempfile], settings.thumbnail_resize)
      @img_path = r[0]
      @img_thumbnail_path = r[1]
      @img_tag = inline_image_tag(@img_thumbnail_path)
      erb :image
    end

    get '/stream_editor/data' do
      auth!
      @entries = Guru.directory_hash('./content', 'content')
      json @entries
    end

    #************************************************************************************************
    # Shop editor
    #************************************************************************************************

    get '/shop_editor' do
      auth!
      erb :shop
    end

    #************************************************************************************************
    # Shop checkout
    # TODO: move to go microservice
    #************************************************************************************************

    post '/checkout' do
      log "\n checkout params #{params}"
      #redirect 'http://localhost:1313/item'
      200
    end


    #************************************************************************************************
    # Form notify via sendmail
    # TODO: move out
    #************************************************************************************************

    get '/se' do
      erb :se
    end

    post '/se' do
      log "\n ems #{params}"
      msg = params[:msg]
      to_customer = params[:to]
      to_business = settings.sendform_to_business
        x = `echo "#{msg}" | mail -s "#{settings.sendform_subject}" -r #{settings.sendform_from} -c #{to_business} #{to_customer} 2>&1`
        if $?.success?
          200
        else
          405
        end
    end

    #************************************************************************************************
    # Helper methods
    #************************************************************************************************

    def set_message(msg)
      @message = msg
    end

    def auth!
      env['warden'].authenticate!
    end

    def log(msg)
      puts msg
      logger.info msg
    end

    def mimetype(path)
      `file -Ib #{path}`.gsub(/\n/,"")
    end

    def image_tag(path)
      #%(<img src="#{path.gsub(/\.\/content/, '')}"/>)
      p = path
      if path =~ /\A\.\/content/
        p = path.gsub(/\.\/content/, '')
      elsif path =~ /\A\.\/themes/
        p = File.join( path.gsub(/\.\/themes/, '').split('/')[2..-1] )
      end
      %(![#{File.basename(p)}](#{p}))
    end

    def inline_image_tag(path)
      %(<img src="data:#{mimetype(path)};base64,#{Base64.encode64(File.read(path))}"/>)
    end
  end # class Kit
end # module Rubyongo
