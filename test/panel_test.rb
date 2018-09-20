require "test_helper"

class Panel < Rubyongo::Test

  def test_the_version_number
    refute_nil ::Rubyongo.version
  end

  def test_panel_test_path
    get '/test'
    assert_match 'TEST', last_response.body
  end

  def test_panel_microservice_path
    get '/microservice'
    assert_match '369', last_response.body
  end
end