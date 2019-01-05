require 'rubyongo/rack/secs/version'
require 'rack'

module Rubyongo
module Rack
  module Secs
    autoload :AuthenticityToken,     'rubyongo/rack/secs/authenticity_token'
    autoload :Base,                  'rubyongo/rack/secs/base'
    autoload :CookieTossing,         'rubyongo/rack/secs/cookie_tossing'
    autoload :ContentSecurityPolicy, 'rubyongo/rack/secs/content_security_policy'
    autoload :EscapedParams,         'rubyongo/rack/secs/escaped_params'
    autoload :FormToken,             'rubyongo/rack/secs/form_token'
    autoload :FrameOptions,          'rubyongo/rack/secs/frame_options'
    autoload :HttpOrigin,            'rubyongo/rack/secs/http_origin'
    autoload :IPSpoofing,            'rubyongo/rack/secs/ip_spoofing'
    autoload :JsonCsrf,              'rubyongo/rack/secs/json_csrf'
    autoload :PathTraversal,         'rubyongo/rack/secs/path_traversal'
    autoload :RemoteReferrer,        'rubyongo/rack/secs/remote_referrer'
    autoload :RemoteToken,           'rubyongo/rack/secs/remote_token'
    autoload :SessionHijacking,      'rubyongo/rack/secs/session_hijacking'
    autoload :StrictTransport,       'rubyongo/rack/secs/strict_transport'
    autoload :XSSHeader,             'rubyongo/rack/secs/xss_header'

    def self.new(app, options = {})
      # does not include: RemoteReferrer, AuthenticityToken and FormToken
      except = Array options[:except]
      use_these = Array options[:use]

      if options.fetch(:without_session, false)
        except += [:session_hijacking, :remote_token]
      end

      ::Rack::Builder.new do
        # Off by default, unless added
        use ::Rubyongo::Rack::Secs::AuthenticityToken,     options if use_these.include? :authenticity_token
        use ::Rubyongo::Rack::Secs::CookieTossing,         options if use_these.include? :cookie_tossing
        use ::Rubyongo::Rack::Secs::ContentSecurityPolicy, options if use_these.include? :content_security_policy
        use ::Rubyongo::Rack::Secs::FormToken,             options if use_these.include? :form_token
        use ::Rubyongo::Rack::Secs::RemoteReferrer,        options if use_these.include? :remote_referrer
        use ::Rubyongo::Rack::Secs::StrictTransport,       options if use_these.include? :strict_transport

        # On by default, unless skipped
        use ::Rubyongo::Rack::Secs::FrameOptions,          options unless except.include? :frame_options
        use ::Rubyongo::Rack::Secs::HttpOrigin,            options unless except.include? :http_origin
        use ::Rubyongo::Rack::Secs::IPSpoofing,            options unless except.include? :ip_spoofing
        use ::Rubyongo::Rack::Secs::JsonCsrf,              options unless except.include? :json_csrf
        use ::Rubyongo::Rack::Secs::PathTraversal,         options unless except.include? :path_traversal
        use ::Rubyongo::Rack::Secs::RemoteToken,           options unless except.include? :remote_token
        use ::Rubyongo::Rack::Secs::SessionHijacking,      options unless except.include? :session_hijacking
        use ::Rubyongo::Rack::Secs::XSSHeader,             options unless except.include? :xss_header
        run app
      end.to_app
    end
  end
end
end