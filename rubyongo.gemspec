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

  s.files         = Dir['LICENSE', 'README.md', 'ROG_VERSION', 'lib/**/*',  'exe/**/*', 'gen/**/*',
                        'themes/**/*', 'views/**/*', 'panel/**/*', 'panel.yml', 'config.ru']
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rack', '~>1.6.4'
  s.add_dependency 'rack-contrib', '~>1.6'
  s.add_dependency 'rack-test', '~>0.6.3'
  s.add_dependency 'sinatra'
  s.add_dependency 'sinatra-contrib'
  s.add_dependency 'sinatra-flash'
  s.add_dependency 'addressable', '2.3.7'
  s.add_dependency 'bcrypt-ruby'
  s.add_dependency 'warden'
  s.add_dependency 'json'
  s.add_dependency 'dm-core'
  s.add_dependency 'dm-sqlite-adapter'
  s.add_dependency 'dm-migrations'
  s.add_dependency 'dm-serializer'
  s.add_dependency 'dm-timestamps'
  s.add_dependency 'dm-transactions'
  s.add_dependency 'dm-types'
  s.add_dependency 'dm-validations'

  s.add_development_dependency "bundler", "~> 1.16"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest", "~> 5.0"

end
