require "spec_helper"

describe Rubyongo::Rack::Secs::SessionHijacking do
  it_behaves_like "any rack application"

  it "accepts a session without changes to tracked parameters" do
    session = {:foo => :bar}
    get '/', {}, 'rack.session' => session
    get '/', {}, 'rack.session' => session
    expect(session[:foo]).to eq(:bar)
  end

  it "denies requests with a changing User-Agent header" do
    session = {:foo => :bar}
    get '/', {}, 'rack.session' => session, 'HTTP_USER_AGENT' => 'a'
    get '/', {}, 'rack.session' => session, 'HTTP_USER_AGENT' => 'b'
    expect(session).to be_empty
  end

  it "accepts requests with a changing Accept-Encoding header" do
    # this is tested because previously it led to clearing the session
    session = {:foo => :bar}
    get '/', {}, 'rack.session' => session, 'HTTP_ACCEPT_ENCODING' => 'a'
    get '/', {}, 'rack.session' => session, 'HTTP_ACCEPT_ENCODING' => 'b'
    expect(session).not_to be_empty
  end

  it "denies requests with a changing Accept-Language header" do
    session = {:foo => :bar}
    get '/', {}, 'rack.session' => session, 'HTTP_ACCEPT_LANGUAGE' => 'a'
    get '/', {}, 'rack.session' => session, 'HTTP_ACCEPT_LANGUAGE' => 'b'
    expect(session).to be_empty
  end

  it "accepts requests with the same Accept-Language header" do
    session = {:foo => :bar}
    get '/', {}, 'rack.session' => session, 'HTTP_ACCEPT_LANGUAGE' => 'a'
    get '/', {}, 'rack.session' => session, 'HTTP_ACCEPT_LANGUAGE' => 'a'
    expect(session).not_to be_empty
  end

  it "comparison of Accept-Language header is not case sensitive" do
    session = {:foo => :bar}
    get '/', {}, 'rack.session' => session, 'HTTP_ACCEPT_LANGUAGE' => 'a'
    get '/', {}, 'rack.session' => session, 'HTTP_ACCEPT_LANGUAGE' => 'A'
    expect(session).not_to be_empty
  end

  it "accepts requests with a changing Version header"do
    session = {:foo => :bar}
    get '/', {}, 'rack.session' => session, 'HTTP_VERSION' => '1.0'
    get '/', {}, 'rack.session' => session, 'HTTP_VERSION' => '1.1'
    expect(session[:foo]).to eq(:bar)
  end
end
