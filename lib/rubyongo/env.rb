# Environment
module Rubyongo
  def self.env
    ENV['RACK_ENV']
  end

  def self.production?
    Rubyongo.env == 'production'
  end

  def self.development?
    Rubyongo.env == 'development'
  end

  def self.test?
    Rubyongo.env == 'test'
  end
end
