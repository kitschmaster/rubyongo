# frozen_string_literal: true

require 'rack/body_proxy'
require 'rack/utils'

module Rubyongo
module Rack
  class RoggerLogger
    def initialize(app, logger = nil)
      @app = app
      @logger = logger
    end

    def call(env)
      began_at = Time.now # Rack::Utils.clock_time
      status, header, body = @app.call(env)
      header = ::Rack::Utils::HeaderHash.new(header)
      body = ::Rack::BodyProxy.new(body) { log(env, status, header, began_at) }
      [status, header, body]
    end

    private

    def log(env, status, header, began_at)
      # length = extract_content_length(header)

      msg = JSON.dump({
        #remote_ip: env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-",
        #remote_user: env["REMOTE_USER"] || "-",
        #time: Time.now.strftime("%d/%b/%Y:%H:%M:%S %z"),
        #http_version: env['HTTP_VERSION'],
        status: status.to_s[0..3],
        # length: length,
        elapsed: Time.now - began_at,
        method: env['REQUEST_METHOD'],
        path: env['PATH_INFO'],
        #query_string: env['QUERY_STRING'],
        params: filter(env["rack.request.form_hash"])
      })

      logger = @logger || env['rack.errors']
      # Standard library logger doesn't support write but it supports << which actually
      # calls to write on the log device without formatting
      if logger.respond_to?(:write)
        logger.write(msg+"\n")
      else
        logger << msg+"\n"
      end
    end

    def extract_content_length(headers)
      value = headers[::Rack::CONTENT_LENGTH] or return '-'
      value.to_s == '0' ? '-' : value
    end

    def filter(hash)
      return "" unless hash # no params
      hash['guru']['password'] = "***" if hash['guru']
      hash['password'] = "***" if hash['password']
      hash
    end
  end
end
end