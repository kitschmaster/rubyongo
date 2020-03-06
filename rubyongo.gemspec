# coding: utf-8

version = File.read(File.expand_path('../ROG_VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name          = "rubyongo"
  s.version       = version
  s.authors       = ["Miha Plohl"]
  s.email         = ["kitschmaster@gmail.com"]

  s.summary       = %q{A webshop framework.}
  s.description   = %q{Ruby On Go is a webshop framework for the real world (deployable to shared hosting). It combines static frontend generation together with an extendable content editor integrated with a microservice Bitcoin merchant.}
  s.homepage      = "http://rubyongo.org"
  s.license       = "MIT"

  s.files         = Dir['LICENSE', 'README.md', 'ROG_VERSION',
                        'lib/**/*',  'exe/**/*', 'gen/**/*', 'gen/.gitignore',
                        'themes/**/*', 'panel/**/*', 'panel.yml', 'config.ru',
                        'static/**/*',
                        'sys/**/*', 'sys/host_vars/.gitignore', 'sys/host_files/.gitignore', 'sys/keys/.gitignore']
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rack', '~>2.2'
  s.add_dependency 'rack-contrib', '~>2'
  s.add_dependency 'rack-test', '~>1.1.0'
  s.add_dependency 'sinatra', '~>2'
  s.add_dependency 'sinatra-contrib', '~>2'
  s.add_dependency 'sinatra-flash', '~>0.3'
  s.add_dependency 'addressable', '2.3.7'
  s.add_dependency 'bcrypt-ruby', '~>3.1'
  s.add_dependency 'warden', '~>1.2'
  s.add_dependency 'json', '~>1.8'
  s.add_dependency 'dm-core', '~>1.2'
  s.add_dependency 'dm-sqlite-adapter', '~>1.2'
  s.add_dependency 'dm-migrations', '~>1.2'
  s.add_dependency 'dm-serializer', '~>1.2'
  s.add_dependency 'dm-timestamps', '~>1.2'
  s.add_dependency 'dm-transactions', '~>1.2'
  s.add_dependency 'dm-types', '~>1.2'
  s.add_dependency 'dm-validations', '~>1.2'
  s.add_dependency 'sysrandom', '~>1.0'

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake", "~>12.3"
  s.add_development_dependency "minitest", "~>5.0"
  s.add_development_dependency "minitest-capybara", "~>0.9"
  s.add_development_dependency "nokogiri", "~>1.6"
  s.add_development_dependency "capybara", "~>2.18"
  s.add_development_dependency "poltergeist", "~>1"
  s.add_development_dependency "rspec", "~> 3.6"
end
