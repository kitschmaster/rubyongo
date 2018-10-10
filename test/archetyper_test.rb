require "test_helper"

class ArchetyperTest < Minitest::Test

  def test_archetyper_listing_archetypes
    assert_equal Rubyongo::Archetyper.archetypes.sort, ["item", "page", "post", "project"].sort
  end

end