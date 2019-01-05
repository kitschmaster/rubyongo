require "spec_helper"

describe Rubyongo::Rack::Secs::HttpOrigin do
  it_behaves_like "any rack application"

  before(:each) do
    mock_app do
      use Rubyongo::Rack::Secs::HttpOrigin
      run DummyApp
    end
  end

  %w(GET HEAD POST PUT DELETE).each do |method|
    it "accepts #{method} requests with no Origin" do
      expect(send(method.downcase, '/')).to be_ok
    end
  end

  %w(GET HEAD).each do |method|
    it "accepts #{method} requests with non-whitelisted Origin" do
      expect(send(method.downcase, '/', {}, 'HTTP_ORIGIN' => 'http://malicious.com')).to be_ok
    end
  end

  %w(GET HEAD POST PUT DELETE).each do |method|
    it "accepts #{method} requests when allow_if is true" do
      mock_app do
        use Rubyongo::Rack::Secs::HttpOrigin, :allow_if => lambda{|env| env.has_key?('HTTP_ORIGIN') }
        run DummyApp
      end
      expect(send(method.downcase, '/', {}, 'HTTP_ORIGIN' => 'http://any.domain.com')).to be_ok
    end
  end

  %w(POST PUT DELETE).each do |method|
    it "denies #{method} requests with non-whitelisted Origin" do
      expect(send(method.downcase, '/', {}, 'HTTP_ORIGIN' => 'http://malicious.com')).not_to be_ok
    end

    it "accepts #{method} requests with whitelisted Origin" do
      mock_app do
        use Rubyongo::Rack::Secs::HttpOrigin, :origin_whitelist => ['http://www.friend.com']
        run DummyApp
      end
      expect(send(method.downcase, '/', {}, 'HTTP_ORIGIN' => 'http://www.friend.com')).to be_ok
    end
  end
end
