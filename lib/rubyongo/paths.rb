module Rubyongo

  # Constants
  IMAGE_FILES    = [ 'jpg', 'jpeg', 'gif', 'png', 'bmp' ]
  TEXT_FILES     = [ 'txt', 'text', 'toml', 'md', 'js',
                     'json', 'css', 'html', 'htm', 'xml',
                     'c', 'cpp', 'h', 'sql', 'log', 'py',
                     'rb', 'htaccess', 'php' ]
  DEFAULT_THEME  = 'default'

  # Paths
  GEM_PATH       = File.join(File.dirname(__FILE__), '..', '..')
  EXEC_PATH      = Dir.pwd # Where to run from - the framework user's path
  HUGO_RUN_PATH  = ENV['GOROOT'] ? File.join(ENV['GOROOT'], 'bin', 'hugo') : 'hugo'
  CONFIG_PATH    = File.join(EXEC_PATH, 'config.toml')
  CONTENT_PATH   = File.join(EXEC_PATH, 'content')
  PUBLIC_PATH    = File.join(EXEC_PATH, 'public')
  THEMES_PATH    = File.join(EXEC_PATH, 'themes')

  # Guru libs
  GURU_LIB       = File.join(File.dirname(__FILE__), 'guru', '**', '*.rb')

  # User's Panel
  PANEL_PATH            = File.join(EXEC_PATH, 'panel')
  PANEL_VIEWS_PATH      = File.join(PANEL_PATH, 'views')
  PANEL_PUBLIC_PATH     = File.join(PANEL_PATH, 'public')
  PANEL_CONFIG_PATH     = File.join(EXEC_PATH, 'panel.yml')

  # Guru's Panel
  PANEL_LIB             = File.join(PANEL_PATH, 'lib', '**', '*.rb')
  PANEL_LIB_PUBLIC_PATH = File.join(File.dirname(__FILE__), 'panel', 'public')
end

