require "test_helper"

class RubyongoTest < Minitest::Test

  def test_that_it_has_a_version_number
    refute_nil ::Rubyongo.version
  end
end