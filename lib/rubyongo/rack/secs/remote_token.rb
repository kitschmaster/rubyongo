require 'rubyongo/rack/secs'

module Rubyongo
module Rack
  module Secs
    ##
    # Prevented attack::   CSRF
    # Supported browsers:: all
    # More infos::         http://en.wikipedia.org/wiki/Cross-site_request_forgery
    #
    # Only accepts unsafe HTTP requests if a given access token matches the token
    # included in the session *or* the request comes from the same origin.
    #
    # Compatible with rack-csrf.
    class RemoteToken < AuthenticityToken
      default_reaction :deny

      def accepts?(env)
        super or referrer(env) == ::Rack::Request.new(env).host
      end
    end
  end
end
end